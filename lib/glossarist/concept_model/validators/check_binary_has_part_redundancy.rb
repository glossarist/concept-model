# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckBinaryHasPartRedundancy — detects redundancy between
      # binary has_part / is_part_of edges and PartitiveRelations.
      #
      # The same semantic concept (part-of) is modeled two ways:
      #   - Binary edge: related: [{type: has_part, ref: X}]
      #   - N-ary relation: partitive_relations: [{comprehensive, partitives, ...}]
      #
      # If a PartitiveRelation asserts A → {b, c, d}, binary has_part
      # edges for the same pairs are redundant. The PartitiveRelation
      # subsumes them.
      #
      # Also warns on binary has_part clusters (3+ edges from the same
      # concept) — these often indicate a PartitiveRelation was intended.
      #
      # This is a warning validator (exit 0) — redundancy is harmless
      # data-wise, just wasteful. Forcing a hard error would block
      # transitional data.
      class CheckBinaryHasPartRedundancy < Glossarist::ConceptModel::Validator
        HAS_PART_TYPES = %w[has_part is_part_of].freeze

        def run
          warnings = []

          each_concept_yaml do |path, docs|
            doc = docs.first
            next unless doc.is_a?(Hash)

            relations = doc["partitive_relations"] || []
            related   = doc["related"] || []

            partitive_refs = relations.flat_map do |rel|
              (rel["partitives"] || []).map { |m| ref_key(m["ref"]) }
            end.compact.to_set

            binary_refs = related
              .select { |r| HAS_PART_TYPES.include?(r["type"]) }
              .map { |r| ref_key(r["ref"]) }
              .compact.to_set

            (partitive_refs & binary_refs).each do |ref|
              warnings << "#{relative(path)}: binary has_part edge for #{ref} is redundant (already in a PartitiveRelation)"
            end

            if binary_refs.length >= 3
              warnings << "#{relative(path)}: #{binary_refs.length} binary has_part edges — consider converting to a PartitiveRelation"
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }
          ok("OK: redundancy check complete (#{warnings.length} warnings, see stderr)")
        end

        private

        def ref_key(ref)
          return nil unless ref.is_a?(Hash)
          "#{ref['source']}:#{ref['id']}"
        end

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
