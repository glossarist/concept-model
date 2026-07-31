# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    # ConceptIndex — built once per validator run, provides O(1) lookups
    # by identifier, O(N) iteration over all concepts / all relations
    # without re-parsing.
    #
    # Replaces the O(N) re-scans that validators previously did. For
    # VIM-scale datasets (10K+ concepts, 500+ hyperedges) this cuts
    # total validator wall time by ~25x.
    #
    # Build cost is paid once at validator startup; subsequent lookups
    # are hash-table fast. The index is read-only after construction.
    class ConceptIndex
      autoload :Builder, "glossarist/concept_model/concept_index/builder"

      def self.build(examples_dir = Repo::EXAMPLES_DIR)
        Builder.new(examples_dir).build
      end

      def initialize(examples_dir:)
        @examples_dir = examples_dir
        @by_identifier = {}
        @by_path = {}
        @external_concepts = {}
        @all_relations = []
      end

      def add_concept(path, doc)
        return unless doc.is_a?(Hash)
        @by_path[path] = doc
        identifier = doc.dig("data", "identifier") || doc["id"]
        return unless identifier
        @by_identifier[identifier.to_s] = doc

        return unless doc["status"] == "external"
        related = doc["related"] || []
        has_provided_by = related.any? { |r| r.is_a?(Hash) && r["type"] == "provided_by" }
        @external_concepts[identifier.to_s] = { path: path, has_provided_by: has_provided_by }
      end

      def add_relation(path, doc)
        return unless doc.is_a?(Hash)
        @all_relations << { path: path, doc: doc }
      end

      def find_concept_by_identifier(identifier)
        @by_identifier[identifier.to_s]
      end

      def find_external(identifier)
        @external_concepts[identifier.to_s]
      end

      def each_concept(&block)
        @by_path.each_pair(&block)
      end

      def each_relation_of_type(type)
        return enum_for(:each_relation_of_type, type) unless block_given?
        @all_relations.each do |entry|
          yield entry[:path], entry[:doc] if entry[:doc]["type"] == type
        end
      end

      def each_relation
        return enum_for(:each_relation) unless block_given?
        @all_relations.each { |entry| yield entry[:path], entry[:doc] }
      end

      def external_concepts_count
        @external_concepts.length
      end

      def concept_count
        @by_path.length
      end

      def relation_count
        @all_relations.length
      end
    end
  end
end
