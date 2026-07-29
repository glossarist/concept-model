# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckRelationFileShape — validates the per-file format of
      # standalone n-ary relation files.
      #
      # Each relation file must:
      #   1. Have a $id matching the pattern <comprehensive-id>/<criterion-slug>
      #   2. Have a valid `type` (partitive_relation or generic_relation)
      #   3. Have a `comprehensive` matching the directory name
      #   4. Have `members` with at least 2 entries
      #
      # Also enforces the clean-break: no concept file should still carry
      # an inline `partitive_relations` or `generic_relations` array.
      class CheckRelationFileShape < Glossarist::ConceptModel::Validator
        ID_PATTERN = /\A[a-z0-9][a-z0-9-]*\/[a-z0-9][a-z0-9-]*\z/
        VALID_TYPES = %w[partitive_relation generic_relation].freeze

        def run
          failures = []

          check_relation_files(failures)
          check_no_bundled_relations(failures)

          if failures.empty?
            ok("OK: all relation files well-formed; no bundled arrays in concept files")
          else
            fail_with("FAIL: #{failures.length} shape issue(s)", failures)
          end
        end

        private

        def check_relation_files(failures)
          relations_dir = Repo::EXAMPLES_DIR / "relations"
          return unless relations_dir.exist?

          Dir.glob("#{relations_dir}/**/*.yaml").sort.each do |path|
            check_one_relation_file(Pathname.new(path), failures)
          end
        end

        def check_one_relation_file(path, failures)
          doc = YAML.load_file(path)
          return unless doc.is_a?(Hash)

          id = doc["$id"]
          type = doc["type"]
          comp = doc["comprehensive"]
          members = doc["members"]

          unless id && id.match?(ID_PATTERN)
            failures << "#{relative(path)}: $id #{id.inspect} must match <comprehensive-id>/<criterion-slug>"
          end

          unless VALID_TYPES.include?(type)
            failures << "#{relative(path)}: type #{type.inspect} must be one of #{VALID_TYPES.join(', ')}"
          end

          if comp && id
            dir_part = id.split("/").first
            expected_dir = "#{comp['source']}-#{comp['id']}".downcase.gsub(/[^a-z0-9-]/, "-").gsub(/-+/, "-")
            unless dir_part == expected_dir
              failures << "#{relative(path)}: $id #{id.inspect} directory #{dir_part.inspect} does not match comprehensive #{expected_dir.inspect}"
            end
          end

          member_count = members.to_a.length
          if member_count < 2
            failures << "#{relative(path)}: members count #{member_count} (ISO 704 requires >= 2)"
          end
        end

        def check_no_bundled_relations(failures)
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            YAML.load_stream(File.read(path)).each do |doc|
              next unless doc.is_a?(Hash)
              if doc["partitive_relations"]
                failures << "#{relative(Pathname.new(path))}: still carries inline partitive_relations (use per-file format)"
              end
              if doc["generic_relations"]
                failures << "#{relative(Pathname.new(path))}: still carries inline generic_relations (use per-file format)"
              end
            end
          end
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
