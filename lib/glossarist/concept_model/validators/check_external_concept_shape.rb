# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckExternalConceptShape — asserts coherence rules for
      # ManagedConcepts with status: external:
      #
      #   1. Must NOT have a definition (contradicts external status)
      #   2. Must NOT have sources (contradicts external status)
      #   3. Must have at least one designation (need a name to reference by)
      class CheckExternalConceptShape < Glossarist::ConceptModel::Validator
        def run
          failures = []

          each_concept_yaml do |path, docs|
            doc = docs.first
            next unless doc.is_a?(Hash)
            next unless doc["status"] == "external"

            data = doc["data"] || {}

            if data["definition"] && !data["definition"].empty?
              failures << "#{relative(path)}: external concept has a definition (contradicts status: external)"
            end

            if data["sources"] && !data["sources"].empty?
              failures << "#{relative(path)}: external concept has sources (contradicts status: external)"
            end

            designations = data["designations"] || []
            if designations.empty?
              failures << "#{relative(path)}: external concept has no designations (need at least one name)"
            end
          end

          if failures.empty?
            ok("OK: all ExternalConcepts are well-formed")
          else
            fail_with("FAIL: #{failures.length} ExternalConcept shape issue(s)", failures)
          end
        end

        private

        def each_concept_yaml
          # Skip the _negative/ directory — those are intentionally
          # broken examples for the negative-example validator.
          Dir.glob("#{Repo::EXAMPLES_DIR}/**/*.yaml").sort.each do |path|
            next if path.include?("/_negative/")
            yield Pathname.new(path), YAML.load_stream(File.read(path))
          end
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
