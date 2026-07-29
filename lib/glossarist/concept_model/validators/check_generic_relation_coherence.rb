# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckGenericRelationCoherence — asserts ISO 704 / 12620
      # invariants on GenericRelations stored as per-file relations.
      #
      # Mirrors CheckPartitiveRelationCoherence. The shared logic lives
      # in NaryCoherence (DRY); this validator provides the per-file
      # enumeration and the type label for error messages.
      class CheckGenericRelationCoherence < Glossarist::ConceptModel::Validator
        include NaryCoherence

        TYPE_LABEL = "GenericRelation"
        RELATIONS_DIR = Repo::EXAMPLES_DIR / "relations"

        def run
          @paths_per_id = {}
          failures, warnings = run_coherence_checks(TYPE_LABEL)

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          if failures.empty?
            ok("OK: all GenericRelations coherent (#{warnings.length} warnings)")
          else
            fail_with("FAIL: #{failures.length} coherence issue(s)", failures)
          end
        end

        # Yields (path, comprehensive_id, relation_hash) for each
        # GenericRelation file in the relations/ directory.
        def each_relation
          return unless RELATIONS_DIR.exist?

          Dir.glob("#{RELATIONS_DIR}/**/*.yaml").sort.each do |path|
            pathname = Pathname.new(path)
            doc = YAML.load_file(path)
            next unless doc.is_a?(Hash) && doc["type"] == "generic_relation"

            comp_id = (doc["comprehensive"] || {}).then { |c| "#{c['source']}:#{c['id']}" }
            yield pathname, comp_id, doc
          end
        end
      end
    end
  end
end
