# frozen_string_literal: true

require "yaml"
require "json_schemer"

module Glossarist
  module ConceptModel
    module Validators
      # ValidateExamples — validates every YAML file under
      # schemas/v3/examples/ against the appropriate schema.
      #
      # Schema choice:
      #   - "*-localized*", "*-designation-*", etc. → localized-concept.yaml
      #   - "*-register*"                            → register.yaml
      #   - otherwise                                → concept.yaml
      #
      # Multi-doc files: doc 0 uses the filename-indicated schema;
      # docs 1..N use localized-concept.
      class ValidateExamples < Glossarist::ConceptModel::Validator
        def run
          files = Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort
          return fail_with("no example files found under #{Repo::EXAMPLES_DIR}") if files.empty?

          schemas = load_schemas
          failures = []

          files.each do |path|
            primary_schema_name = schema_for_filename(File.basename(path))
            primary_schema = schemas[primary_schema_name]
            loc_schema     = schemas["localized-concept"]

            docs = YAML.load_stream(File.read(path))
            docs.each_with_index do |doc, i|
              next if doc.nil?
              schema = (i.zero? ? primary_schema : loc_schema)
              schemer = JSONSchemer.schema(schema, format: false)
              unless schemer.valid?(doc)
                errors = schemer.validate(doc).to_a
                label = errors.map { |e| e.fetch("error", e.inspect) }.first
                failures << "#{File.basename(path)}[doc #{i}]: #{label} (against #{basename_for(schema)})"
              end
            end
          end

          if failures.empty?
            ok("OK: #{files.length} example files validated")
          else
            fail_with("FAIL: #{failures.length} example doc(s) failed validation", failures)
          end
        end

        private

        def load_schemas
          {
            "concept"          => YAML.load_file(Repo::CONCEPT_SCHEMA),
            "localized-concept" => YAML.load_file(Repo::LOCALIZED_SCHEMA),
            "register"         => YAML.load_file(Repo::REGISTER_SCHEMA),
          }
        end

        def schema_for_filename(name)
          lower = name.downcase
          return "register"          if Repo::REGISTER_MARKERS.any? { |m| lower.include?(m) }
          return "localized-concept" if Repo::LOCALIZED_MARKERS.any? { |m| lower.include?(m) }
          "concept"
        end

        def basename_for(schema_hash)
          case schema_hash
          when YAML.load_file(Repo::CONCEPT_SCHEMA)    then "concept.yaml"
          when YAML.load_file(Repo::LOCALIZED_SCHEMA)  then "localized-concept.yaml"
          when YAML.load_file(Repo::REGISTER_SCHEMA)   then "register.yaml"
          else "<unknown>"
          end
        end
      end
    end
  end
end
