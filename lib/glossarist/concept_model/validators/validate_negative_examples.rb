# frozen_string_literal: true

require "yaml"
require "json_schemer"

module Glossarist
  module ConceptModel
    module Validators
      # ValidateNegativeExamples — asserts that every YAML in
      # schemas/v3/examples/_negative/ FAILS validation. If any
      # negative example passes, the schema has been loosened too far.
      #
      # Files marked with `EXPECT_PASS` in their header comment are
      # documented known-gaps — the runner skips them but reports
      # the count for visibility.
      class ValidateNegativeExamples < Glossarist::ConceptModel::Validator
        def run
          return fail_with("no negative examples found under #{Repo::NEGATIVE_EXAMPLES}") unless Dir.exist?(Repo::NEGATIVE_EXAMPLES)

          files = Dir.glob("#{Repo::NEGATIVE_EXAMPLES}/*.yaml").sort
          return fail_with("no negative example files found") if files.empty?

          concept_schema = JSONSchemer.schema(YAML.load_file(Repo::CONCEPT_SCHEMA), format: false)

          failures = []
          skipped  = []

          files.each do |path|
            text = File.read(path)
            doc  = YAML.load(text)
            next if doc.nil?

            if text.include?("EXPECT_PASS")
              if concept_schema.valid?(doc)
                skipped << File.basename(path)
              else
                failures << "#{File.basename(path)}: documented as EXPECT_PASS but rejected"
              end
              next
            end

            if concept_schema.valid?(doc)
              failures << "#{File.basename(path)}: expected to FAIL but passed"
            end
          end

          if failures.empty?
            message = if skipped.empty?
              "OK: #{files.length} negative examples correctly rejected"
            else
              "OK: #{files.length - skipped.length} negative examples correctly rejected" \
                " (#{skipped.length} skipped as documented known gaps)"
            end
            ok(message)
          else
            fail_with("FAIL: #{failures.length} negative example(s) passed validation", failures)
          end
        end
      end
    end
  end
end
