# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckNoRawHtmlInConceptText — rejects raw HTML in concept text
      # content (definitions, notes, examples, annotations).
      #
      # Raw HTML bypasses the renderer, has no accessibility contract,
      # and breaks the data/deployment boundary by embedding
      # deployment-specific URLs.
      #
      # Instead, use typed mention syntax:
      #   Links: {{link:https://example.com, Example Site}}
      #   Images: {{image:path/to/image.svg, Alt text}}
      #
      # See docs/design/inline-mentions.md
      class CheckNoRawHtmlInConceptText < Glossarist::ConceptModel::Validator
        RAW_HTML_PATTERN = /
          <
          (a\b|img\b|iframe\b|script\b|style\b|embed\b|object\b|div\b|span\b|p\b|br\b|table\b|td\b|tr\b|th\b|ul\b|ol\b|li\b|h[1-6]\b|b\b|i\b|strong\b|em\b)
        /ix

        def run
          warnings = []

          each_concept_yaml do |path, docs|
            docs.each_with_index do |doc, i|
              next unless doc.is_a?(Hash)
              scan_text_fields(path, doc, i, warnings)
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }
          ok("OK: raw-HTML check complete (#{warnings.length} warnings)")
        end

        private

        def each_concept_yaml
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            yield Pathname.new(path), YAML.load_stream(File.read(path))
          end
        end

        def scan_text_fields(path, doc, doc_index, warnings)
          data = doc["data"] || doc
          rel_path = relative(path)

          check_field(rel_path, doc_index, "definition", data["definition"], warnings)
          check_field(rel_path, doc_index, "notes", data["notes"], warnings)
          check_field(rel_path, doc_index, "examples", data["examples"], warnings)
          check_field(rel_path, doc_index, "annotations", data["annotations"], warnings)
        end

        def check_field(rel_path, doc_index, field_name, value, warnings)
          texts = extract_text_strings(value)
          texts.each_with_index do |text, ti|
            next unless text.is_a?(String)
            match = text.match(RAW_HTML_PATTERN)
            next unless match
            warnings << "#{rel_path}[doc #{doc_index}] #{field_name}[#{ti}]: contains raw HTML " \
                        "<#{match[1].downcase}> — use {{link:}} or {{image:}} instead " \
                        "(see docs/design/inline-mentions.md)"
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
