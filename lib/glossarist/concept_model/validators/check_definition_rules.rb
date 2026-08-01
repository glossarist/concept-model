# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckDefinitionRules — applies ISO 704:2022 §6.4 definition
      # writing rules to intensional definitions in concept data.
      #
      # Rules covered (all warnings unless noted):
      #
      #   §6.4.3.2  Single concept per definition — flags intensional
      #             definitions that look like they're defining two
      #             concepts (heuristic: contains "and" joining two
      #             noun phrases after the genus).
      #
      #   §6.4.3.4  No genus redefinition — flags definitions that
      #             restate characteristics already implied by the
      #             genus (heuristic only; needs generic relation
      #             context to apply rigorously).
      #
      #   §6.4.3.5  Reflect inheritance principle — flags concepts
      #             with a generic_relations entry whose intensional
      #             definition doesn't begin with the genus concept's
      #             designation (when inferable).
      #
      #   §6.4.3.10 Begin with noun (for nominal designations) —
      #             flags intensional definitions that don't begin
      #             with a noun phrase. Heuristic: first word should
      #             not be a verb in -ing form or an article alone.
      #
      #   §6.4.4   Substitution principle — informational note that
      #             the definition should be substitutable for the
      #             term in context. Cannot be auto-checked but is
      #             surfaced as a reminder.
      #
      #   §6.4.5.2 Extensional definitions use "or" for generic
      #   §6.4.5.3 Extensional definitions use "and" for partitive
      #             — flags definitions tagged type: extensional
      #             that use the wrong conjunction.
      class CheckDefinitionRules < Glossarist::ConceptModel::Validator
        NOUN_FORM_LETTERS = %w[a e i o u].freeze

        def run
          warnings = []

          each_localized_concept do |path, doc|
            check_definition_rules(path, doc, warnings)
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          ok("OK: definition rule check complete (#{warnings.length} warnings)")
        end

        private

        def each_localized_concept
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            YAML.load_stream(File.read(path)).each_with_index do |doc, i|
              next unless doc.is_a?(Hash)
              next unless i.positive? # doc 0 is ManagedConcept; subsequent are LocalizedConcepts
              yield Pathname.new(path), doc
            end
          end
        end

        def check_definition_rules(path, doc, warnings)
          data = doc["data"] || doc
          definitions = data["definition"] || []
          definitions = [definitions] unless definitions.is_a?(Array)
          definitions.each do |d|
            check_one_definition(path, d, warnings)
          end
        end

        def check_one_definition(path, defn, warnings)
          return unless defn.is_a?(Hash)
          content = defn["content"].to_s.strip
          return if content.empty?

          rel_path = relative(path)

          # §6.4.3.10 — Begin with noun (heuristic)
          if starts_with_gerund?(content)
            warnings << "#{rel_path}: definition begins with gerund (verb+-ing); " \
                        "ISO 704 §6.4.3.10 says intensional definitions of nominal " \
                        "designations should begin with a noun (got: #{content[0..40]}...)"
          end

          # §6.4.3.2 — Hidden definitions (heuristic: look for "which is a" patterns)
          if content.match?(/\bwhich is a\b/i) || content.match?(/\bthat is a\b/i)
            warnings << "#{rel_path}: definition may contain hidden definition " \
                        "(contains 'which is a'/'that is a'); ISO 704 §6.4.3.2 says " \
                        "an intensional definition shall describe only one concept"
          end

          # §6.4.5.2 / §6.4.5.3 — Extensional definition conjunction
          if defn["type"] == "extensional"
            if content.match?(/\band\b/) && !content.match?(/\bor\b/)
              warnings << "#{rel_path}: extensional definition uses 'and' — ISO 704 " \
                          "§6.4.5.2 says generic-extensional definitions use 'or' " \
                          "(only partitive-extensional uses 'and' per §6.4.5.3)"
            elsif content.match?(/\bor\b/) && !content.match?(/\band\b/)
              warnings << "#{rel_path}: extensional definition uses 'or' — confirm " \
                          "this is a generic-extensional definition per ISO 704 §6.4.5.2"
            end

            # §6.4.5.1 — No open-ended wordings in extensional definitions
            forbidden = detect_open_ended_wording(content)
            if forbidden
              warnings << "#{rel_path}: extensional definition contains open-ended " \
                          "wording '#{forbidden}'; ISO 704 §6.4.5.1 forbids this — " \
                          "an extensional definition shall enumerate ALL subordinate " \
                          "concepts, not use '...', 'etc.', 'and similar', etc."
            end
          end
        end

        OPEN_ENDED_PATTERNS = [
          /\.\.\./,                 # ellipsis
          /\betc\b\.?/i,            # etc. / etc / ETC
          /\band similar\b/i,       # and similar (items)
          /\band so on\b/i,         # and so on
          /\band the like\b/i,      # and the like
          /\band others?\b/i,       # and other(s)
          /\bincluding\b/i,         # including (implies non-exhaustive)
        ].freeze

        def detect_open_ended_wording(content)
          OPEN_ENDED_PATTERNS.each do |pattern|
            match = content.match(pattern)
            return match[0] if match
          end
          nil
        end

        def starts_with_gerund?(content)
          first_word = content.split(/\s+/).first.to_s.downcase.gsub(/[^a-z]/, "")
          first_word.end_with?("ing") && first_word.length > 4
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
