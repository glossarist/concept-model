# frozen_string_literal: true

require "yaml"
require "json_schemer"

module Glossarist
  module ConceptModel
    module Validators
      # ValidateNegativeExamples — asserts that every YAML under
      # schemas/v3/examples/_negative/ FAILS validation against the
      # schema appropriate to its location.
      #
      # - `_negative/*.yaml`           → validated against concept.yaml
      # - `_negative/relations/*.yaml` → validated against relation.yaml
      #
      # If any negative example passes, the corresponding schema has
      # been loosened too far.
      class ValidateNegativeExamples < Glossarist::ConceptModel::Validator
        RELATION_SCHEMA_PATH = Repo::SCHEMAS_DIR / "relation.yaml"

        # JSONSchemer ref resolver — loads sibling schemas from disk by
        # relative filename. Caches by absolute path.
        def self.sibling_schema_ref_resolver
          cache = {}
          lambda do |uri|
            cache[uri.to_s] ||= begin
              # uri.host is "github.com" — strip; the path's last segment
              # is the filename. We resolve against schemas/v3/.
              filename = uri.path.split("/").last
              candidate = Repo::SCHEMAS_DIR / filename
              if candidate.exist?
                YAML.load_file(candidate)
              else
                raise "cannot resolve schema ref #{uri} — no file at #{candidate}"
              end
            end
          end
        end

        def run
          return fail_with("no negative examples found under #{Repo::NEGATIVE_EXAMPLES}") unless Dir.exist?(Repo::NEGATIVE_EXAMPLES)

          concept_files  = Dir.glob("#{Repo::NEGATIVE_EXAMPLES}/*.yaml").sort
          relation_files = Dir.glob("#{Repo::NEGATIVE_EXAMPLES}/relations/*.yaml").sort

          return fail_with("no negative example files found") if concept_files.empty? && relation_files.empty?

          concept_schema  = JSONSchemer.schema(YAML.load_file(Repo::CONCEPT_SCHEMA), format: false)
          relation_schema = if RELATION_SCHEMA_PATH.exist?
                              JSONSchemer.schema(
                                YAML.load_file(RELATION_SCHEMA_PATH),
                                format: false,
                                ref_resolver: method(:resolve_sibling_ref)
                              )
                            end

          failures = []
          skipped  = []

          concept_files.each do |path|
            validate_against(path, concept_schema, failures, skipped)
          end

          relation_files.each do |path|
            unless relation_schema
              failures << "#{File.basename(path)}: relation.yaml schema missing"
              next
            end
            validate_against(path, relation_schema, failures, skipped)
          end

          total = concept_files.length + relation_files.length

          if failures.empty?
            message = if skipped.empty?
              "OK: #{total} negative examples correctly rejected"
            else
              "OK: #{total - skipped.length} negative examples correctly rejected" \
                " (#{skipped.length} skipped as documented known gaps)"
            end
            ok(message)
          else
            fail_with("FAIL: #{failures.length} negative example(s) passed validation", failures)
          end
        end

        private

        def resolve_sibling_ref(uri)
          filename = uri.path.split("/").last
          candidate = Repo::SCHEMAS_DIR / filename
          if candidate.exist?
            YAML.load_file(candidate)
          else
            raise "cannot resolve schema ref #{uri} — no file at #{candidate}"
          end
        end

        def validate_against(path, schema, failures, skipped)
          text = File.read(path)
          doc  = YAML.load(text)
          return if doc.nil?

          if text.include?("EXPECT_PASS")
            if schema.valid?(doc)
              skipped << File.basename(path)
            else
              failures << "#{File.basename(path)}: documented as EXPECT_PASS but rejected"
            end
            return
          end

          if schema.valid?(doc)
            failures << "#{File.basename(path)}: expected to FAIL but passed"
          end
        end
      end
    end
  end
end

