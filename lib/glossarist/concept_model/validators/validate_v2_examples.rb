# frozen_string_literal: true

require "yaml"
require "json_schemer"

module Glossarist
  module ConceptModel
    module Validators
      # V2 splits managed concepts and localizations into separate files.
      # The data.language_code field identifies a localized concept.
      class ValidateV2Examples < Glossarist::ConceptModel::Validator
        def initialize(examples_dir: Repo::ROOT / "schemas/v2/examples")
          super()
          @examples_dir = examples_dir
        end

        def run
          files = Dir.glob("#{@examples_dir}/**/*.yaml").sort
          return fail_with("no v2 example files found under #{@examples_dir}") if files.empty?

          schemas = %w[concept localized-concept].to_h do |name|
            schema = YAML.load_file(Repo::ROOT / "schemas/v2/#{name}.yaml")
            [name, JSONSchemer.schema(schema)]
          end
          failures = []

          files.each do |path|
            failure_count = failures.length
            docs = YAML.load_stream(File.read(path))
            docs = [nil] if docs.empty?
            docs.each_with_index do |doc, index|
              name = if doc.is_a?(Hash) && doc["data"].is_a?(Hash) && doc["data"].key?("language_code")
                       "localized-concept"
                     else
                       "concept"
                     end
              errors = schemas.fetch(name).validate(doc).to_a
              errors.each do |error|
                failures << "#{File.basename(path)}[doc #{index}] #{error.fetch('data_pointer')}: #{error.fetch('error')} (#{name}.yaml)"
              end
            end
            $stdout.puts "#{File.basename(path)}: #{failures.length > failure_count ? 'FAIL' : 'PASS'}"
          end

          if failures.empty?
            ok("OK: #{files.length} v2 example files validated")
          else
            fail_with("FAIL: #{failures.length} v2 validation error(s)", failures)
          end
        end
      end
    end
  end
end
