# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckInlineMentionsSyntax — validates every {{...}} mention in
      # concept text against the fully declarative grammar.
      #
      # REJECTS all magic combinations:
      #   - Bare text/numbers without kind prefix
      #   - cite with bare local IDs (not DATASET:ID or URN)
      #   - concept with bare IDs (not DATASET:ID or URN)
      #   - link with non-URL targets
      #   - Legacy <<target, caption>> syntax
      #
      # See docs/design/inline-mentions.md for the full grammar.
      class CheckInlineMentionsSyntax < Glossarist::ConceptModel::Validator
        MENTION_PATTERN = /\{\{([^}]+)\}\}/.freeze
        LEGACY_XREF_PATTERN = /<<([^>]+)>>/.freeze

        VALID_KINDS = %w[concept cite fig table formula bib link image].freeze

        # Kinds that require DATASET:ID or URN target (no bare IDs)
        CONCEPT_KINDS = %w[concept cite].freeze

        # Kinds that accept plain IDs (same-dataset) or URN
        ENTITY_KINDS = %w[fig table formula].freeze

        def run
          failures = []
          warnings = []

          each_concept_yaml do |path, docs|
            docs.each_with_index do |doc, i|
              next unless doc.is_a?(Hash)
              scan_text_fields(path, doc, i, failures, warnings)
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          if failures.empty?
            ok("OK: inline mentions syntax valid (#{warnings.length} warnings)")
          else
            fail_with("FAIL: #{failures.length} invalid mention(s)", failures)
          end
        end

        private

        def each_concept_yaml
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            yield Pathname.new(path), YAML.load_stream(File.read(path))
          end
        end

        def scan_text_fields(path, doc, doc_index, failures, warnings)
          data = doc["data"] || doc
          rel_path = relative(path)
          location = "#{rel_path}[doc #{doc_index}]"

          %w[definition notes examples annotations].each do |field|
            texts = extract_text_strings(data[field])
            texts.each_with_index do |text, ti|
              next unless text.is_a?(String)
              scan_one_text(location, field, ti, text, failures, warnings)
            end
          end
        end

        def scan_one_text(location, field, index, text, failures, warnings)
          # Check legacy <<...>> syntax
          text.scan(LEGACY_XREF_PATTERN) do |match|
            warnings << "#{location} #{field}[#{index}]: legacy <<#{match[0]}>> syntax; " \
                        "use {{fig:#{match[0].split(',').first.strip}}}"
          end

          # Check {{...}} mentions
          text.scan(MENTION_PATTERN) do |match|
            raw = match[0].strip
            validate_mention(location, field, index, raw, failures)
          end
        end

        def validate_mention(location, field, index, raw, failures)
          # Split kind:target[, label]
          colon_idx = raw.index(":")
          if colon_idx.nil?
            failures << "#{location} #{field}[#{index}]: '{{#{raw}}}' missing kind prefix; " \
                        "use {{concept:DATASET:ID}} or {{cite:DATASET:ID}}"
            return
          end

          kind = raw[0...colon_idx].strip
          rest = raw[(colon_idx + 1)..]

          # Split target and optional label
          comma_idx = rest.index(",")
          target = comma_idx ? rest[0...comma_idx].strip : rest.strip

          validate_kind(location, field, index, kind, target, raw, failures)
        end

        def validate_kind(location, field, index, kind, target, raw, failures)
          unless VALID_KINDS.include?(kind)
            failures << "#{location} #{field}[#{index}]: '{{#{raw}}}' unknown kind '#{kind}'; " \
                        "must be one of #{VALID_KINDS.join(', ')}"
            return
          end

          if CONCEPT_KINDS.include?(kind)
            validate_concept_target(location, field, index, kind, target, failures)
          elsif ENTITY_KINDS.include?(kind)
            validate_entity_target(location, field, index, kind, target, failures)
          elsif kind == "bib"
            validate_bib_target(location, field, index, target, failures)
          elsif kind == "link"
            validate_link_target(location, field, index, target, failures)
          elsif kind == "image"
            # image accepts any path or URL — no validation needed
          end
        end

        def validate_concept_target(location, field, index, kind, target, failures)
          if target.start_with?("urn:")
            # URN is valid
            return
          end

          unless target.include?(":")
            failures << "#{location} #{field}[#{index}]: '{{#{kind}:#{target}}}' " \
                        "#{kind} target must be DATASET:ID or URN; got bare ID '#{target}'"
            return
          end

          # DATASET:ID format — check that dataset part is non-empty
          dataset = target.rpartition(":").first
          if dataset.empty?
            failures << "#{location} #{field}[#{index}]: '{{#{kind}:#{target}}}' " \
                        "empty dataset qualifier in DATASET:ID"
          end
        end

        def validate_entity_target(location, field, index, kind, target, failures)
          if target.start_with?("urn:")
            # URN is valid for cross-dataset entity references
            return
          end

          # Plain ID is valid for same-dataset entities
          if target.empty?
            failures << "#{location} #{field}[#{index}]: '{{#{kind}:}}' " \
                        "empty entity ID"
          end
        end

        def validate_bib_target(location, field, index, target, failures)
          if target.start_with?("urn:")
            failures << "#{location} #{field}[#{index}]: '{{bib:#{target}}}' " \
                        "bib entries do not have URNs; use plain ID"
            return
          end

          if target.empty?
            failures << "#{location} #{field}[#{index}]: '{{bib:}}' " \
                        "empty bibliography entry ID"
          end
        end

        def validate_link_target(location, field, index, target, failures)
          unless target.match?(/\Ahttps?:\/\//)
            failures << "#{location} #{field}[#{index}]: '{{link:#{target}}}' " \
                        "link target must be https:// or http:// URL"
          end
        end

        def extract_text_strings(value)
          return [] unless value
          return [value] if value.is_a?(String)
          return value.flat_map { |v| extract_text_strings(v) } if value.is_a?(Array)
          return [value["content"]].compact if value.is_a?(Hash) && value["content"]
          return value.flat_map { |_, v| extract_text_strings(v) } if value.is_a?(Hash)
          []
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
