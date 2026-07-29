# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckPartitiveRelationCoherence — asserts ISO 704 / 12620
      # invariants on PartitiveRelations stored as per-file relations.
      #
      # Mirrors CheckGenericRelationCoherence. Shared logic lives in
      # NaryCoherence (DRY); this validator provides the per-file
      # enumeration and the type label for error messages.
      #
      # MECE mapping is owned by Glossarist::ConceptModel::Multiplicity
      # — this validator delegates pair validity and invalid-pair
      # detection to it (single source of truth across validator, JSON
      # Schema, and SHACL shape).
      class CheckPartitiveRelationCoherence < Glossarist::ConceptModel::Validator
        include NaryCoherence

        TYPE_LABEL = "PartitiveRelation"
        RELATIONS_DIR = Repo::EXAMPLES_DIR / "relations"

        def run
          failures, warnings = run_coherence_checks(TYPE_LABEL)

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          if failures.empty?
            ok("OK: all PartitiveRelations coherent (#{warnings.length} warnings)")
          else
            fail_with("FAIL: #{failures.length} coherence issue(s)", failures)
          end
        end

        # Yields (path, comprehensive_id, relation_hash) for each
        # PartitiveRelation file in the relations/ directory.
        def each_relation
          return unless RELATIONS_DIR.exist?

          Dir.glob("#{RELATIONS_DIR}/**/*.yaml").sort.each do |path|
            pathname = Pathname.new(path)
            doc = YAML.load_file(path)
            next unless doc.is_a?(Hash) && doc["type"] == "partitive_relation"

            comp_id = (doc["comprehensive"] || {}).then { |c| "#{c['source']}:#{c['id']}" }
            yield pathname, comp_id, doc
          end
        end
      end
    end
  end
end
