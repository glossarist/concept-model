# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckPartitiveRelationCoherence — asserts ISO 704 / 12620
      # invariants on PartitiveRelations within a dataset:
      #
      #   1. Each relation has ≥2 partitives (ISO "two or more")
      #   2. No duplicate (comprehensive + criterion) on the same concept
      #   3. Warns when a concept has 2+ relations and any lack criterion
      #   4. Warns on multiplicity/delimiting incoherence
      class CheckPartitiveRelationCoherence < Glossarist::ConceptModel::Validator
        def run
          failures = []
          warnings = []

          each_concept_yaml do |path, docs|
            doc = docs.first
            next unless doc.is_a?(Hash)
            relations = doc["partitive_relations"] || []
            next if relations.empty?

            # Check 1: each relation has ≥2 partitives
            relations.each_with_index do |rel, i|
              count = (rel["partitives"] || []).length
              next if count >= 2
              failures << "#{relative(path)}: relation #{i} has #{count} partitives (ISO 704 requires ≥2)"
            end

            # Check 2: no duplicate (comprehensive + criterion)
            seen = {}
            relations.each_with_index do |rel, i|
              comp = rel["comprehensive"]&.then { |c| "#{c['source']}:#{c['id']}" }
              crit = rel["criterion"]&.values&.sort&.join("|")
              next unless comp && crit
              key = "#{comp}|#{crit}"
              if seen[key]
                failures << "#{relative(path)}: relations #{seen[key]} and #{i} are duplicates (same comprehensive + same criterion)"
              else
                seen[key] = i
              end
            end

            # Check 3: warn if multiple relations and any lack criterion
            if relations.length > 1
              relations.each_with_index do |rel, i|
                next if rel["criterion"]
                warnings << "#{relative(path)}: relation #{i} has no criterion; cannot verify distinctness from siblings"
              end
            end

            # Check 4: multiplicity coherence (ISO 704:2022)
            # A delimiting part should not be optional — if it's optional,
            # it can't be relied upon to distinguish the comprehensive from
            # coordinate concepts. Warn (not error) since ISO 704 doesn't
            # explicitly forbid it.
            relations.each_with_index do |rel, i|
              (rel["partitives"] || []).each_with_index do |member, j|
                next unless member["is_delimiting"]
                mult = member["multiplicity"] || "compulsory"
                if mult == "optional" || mult == "optional_multiple"
                  warnings << "#{relative(path)}: relation #{i} partitive #{j} is delimiting but optional (semantically incoherent)"
                end
              end
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          if failures.empty?
            ok("OK: all PartitiveRelations coherent (#{warnings.length} warnings)")
          else
            fail_with("FAIL: #{failures.length} coherence issue(s)", failures)
          end
        end

        private

        def each_concept_yaml
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
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
