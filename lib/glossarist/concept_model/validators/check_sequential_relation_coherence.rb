# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckSequentialRelationCoherence — asserts ISO 12620 A.6.3
      # invariants on SequentialRelations stored as per-file relations.
      #
      # Mirrors CheckPartitiveRelationCoherence and
      # CheckGenericRelationCoherence. The shared logic lives in
      # NaryCoherence (DRY); this validator provides the per-file
      # enumeration and the type label for error messages.
      #
      # Additional sequential-specific check: warns when a member ref
      # appears more than once in the same sequence (suggests the
      # sequence is poorly defined).
      class CheckSequentialRelationCoherence < Glossarist::ConceptModel::Validator
        include NaryCoherence

        TYPE_LABEL = "SequentialRelation"
        RELATIONS_DIR = Repo::EXAMPLES_DIR / "relations"

        def run
          failures = []
          warnings = []

          run_coherence_checks(TYPE_LABEL)
          check_no_duplicate_members_in_sequence(warnings)

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          if failures.empty?
            ok("OK: all SequentialRelations coherent (#{warnings.length} warnings)")
          else
            fail_with("FAIL: #{failures.length} coherence issue(s)", failures)
          end
        end

        def each_relation
          return unless RELATIONS_DIR.exist?

          Dir.glob("#{RELATIONS_DIR}/**/*.yaml").sort.each do |path|
            pathname = Pathname.new(path)
            doc = YAML.load_file(path)
            next unless doc.is_a?(Hash) && doc["type"] == "sequential_relation"

            comp_id = (doc["comprehensive"] || {}).then { |c| "#{c['source']}:#{c['id']}" }
            yield pathname, comp_id, doc
          end
        end

        private

        def check_no_duplicate_members_in_sequence(warnings)
          each_relation do |path, _comp_id, doc|
            refs = (doc["members"] || []).map { |m| m["ref"] && "#{m['ref']['source']}:#{m['ref']['id']}" }
            dups = refs.group_by { |r| r }.select { |_, v| v.length > 1 }.keys
            next if dups.empty?
            warnings << "#{relative(path)}: sequence contains duplicate members: #{dups.join(', ')}"
          end
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
