# frozen_string_literal: true

module Glossarist
  module ConceptModel
    module Validators
      # NaryCoherence — shared logic for n-ary relation coherence checks.
      #
      # Mixed into CheckPartitiveRelationCoherence and
      # CheckGenericRelationCoherence. Each leaf supplies a `type_label`
      # (e.g. "PartitiveRelation") for error messages.
      #
      # All checks are MECE-orthogonal to the schema's structural rules:
      #   1. Cardinality       — each relation has ≥2 members (ISO 704 rake)
      #   2. Duplicate         — no two relations share (comprehensive + criterion)
      #   3. Missing criterion — warn when relations lack criterion
      #   4. Invalid MECE      — reject (optional + at_least_one) combos
      #   5. Delimiting/optional — warn when a delimiting member is optional
      #
      # The MECE validity table is owned by Glossarist::ConceptModel::Multiplicity
      # (single source of truth across validator + JSON Schema + SHACL).
      module NaryCoherence
        DEFAULT_PRESENCE = "required"
        DEFAULT_COUNT = "exactly_one"

        # Returns [failures, warnings] across all relations in the dataset.
        # `each_relation` is supplied by the including validator; it yields
        # `(path, doc_id, relation_hash)` for each n-ary relation found.
        def run_coherence_checks(type_label)
          failures = []
          warnings = []

          # Per-comprehensive (comprehensive_id => [{index, criterion, path}])
          grouped = Hash.new { |h, k| h[k] = [] }

          each_relation do |path, doc_id, rel|
            index_in_file = grouped[doc_id].length
            grouped[doc_id] << { path: path, rel: rel, index: index_in_file }
          end

          grouped.each do |comp_id, entries|
            entries.each do |entry|
              path = entry[:path]
              rel = entry[:rel]
              idx = entry[:index]

              check_cardinality(type_label, path, idx, rel, failures)
              check_invalid_mece(type_label, path, idx, rel, failures)
              check_delimiting_optional(type_label, path, idx, rel, warnings)
            end

            check_duplicate_criterion(type_label, comp_id, entries, failures)
            check_missing_criterion(type_label, comp_id, entries, warnings)
          end

          [failures, warnings]
        end

        private

        def check_cardinality(type_label, path, idx, rel, failures)
          count = (rel["members"] || []).length
          return if count >= 2

          failures << "#{relative(path)}: #{type_label} #{idx} has #{count} members (ISO 704 requires >= 2)"
        end

        def check_duplicate_criterion(type_label, comp_id, entries, failures)
          seen = {}
          entries.each do |e|
            rel = e[:rel]
            crit = rel["criterion"]&.values&.sort&.join("|")
            next unless crit

            key = "#{comp_id}|#{crit}"
            if seen[key]
              failures << "#{relative(e[:path])}: #{type_label} ##{e[:index]} duplicates (#{seen[key]}) " \
                          "(same comprehensive #{comp_id} + same criterion #{crit})"
            else
              seen[key] = e[:index]
            end
          end
        end

        def check_missing_criterion(type_label, comp_id, entries, warnings)
          return unless entries.length > 1

          entries.each do |e|
            next if e[:rel]["criterion"]
            warnings << "#{relative(e[:path])}: #{type_label} on #{comp_id} has no criterion; " \
                         "cannot verify distinctness from siblings"
          end
        end

        def check_invalid_mece(type_label, path, idx, rel, failures)
          (rel["members"] || []).each_with_index do |member, j|
            presence = member["presence"] || DEFAULT_PRESENCE
            count = member["count"] || DEFAULT_COUNT
            next unless Multiplicity.invalid_pair?(presence, count)

            failures << "#{relative(path)}: #{type_label} #{idx} member #{j} has " \
                         "presence=#{presence} + count=#{count} — invalid; " \
                         "an optional part has vacuous at-least-one, " \
                         "use count=multiple instead"
          end
        end

        def check_delimiting_optional(type_label, path, idx, rel, warnings)
          (rel["members"] || []).each_with_index do |member, j|
            next unless member["is_delimiting"]
            presence = member["presence"] || DEFAULT_PRESENCE
            next unless presence == "optional"

            warnings << "#{relative(path)}: #{type_label} #{idx} member #{j} is delimiting but optional (semantically incoherent)"
          end
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
