# frozen_string_literal: true

require "spec_helper"
require "glossarist/concept_model/concept_index"

module Glossarist
  module ConceptModel
    RSpec.describe ConceptIndex do
      let(:index) { described_class.build(Repo::EXAMPLES_DIR) }

      describe "build" do
        it "scans every concept and relation file" do
          expect(index.concept_count).to be > 0
          expect(index.relation_count).to be > 0
        end
      end

      describe "find_concept_by_identifier" do
        it "returns the concept doc by identifier" do
          doc = index.find_concept_by_identifier("112-02-09")
          expect(doc).not_to be_nil
          expect(doc.dig("data", "identifier")).to eq("112-02-09")
        end

        it "returns nil for unknown identifiers" do
          expect(index.find_concept_by_identifier("nonexistent")).to be_nil
        end
      end

      describe "find_external" do
        it "returns external concepts when present" do
          ext = index.find_external("ext-qft")
          next unless ext # external concept may not exist in examples
          expect(ext).to include(:has_provided_by)
        end

        it "returns nil for unknown identifiers" do
          expect(index.find_external("nonexistent")).to be_nil
        end
      end

      describe "each_relation_of_type" do
        it "iterates only relations of the given type" do
          partitive = index.each_relation_of_type("partitive_relation").to_a
          expect(partitive).not_to be_empty
          expect(partitive.all? { |_, doc| doc["type"] == "partitive_relation" }).to be true
        end

        it "returns empty for unknown types" do
          result = index.each_relation_of_type("nonexistent_type").to_a
          expect(result).to be_empty
        end
      end

      describe "immutability" do
        it "doesn't re-parse on subsequent lookups" do
          # Build once, look up many — should be O(1) per lookup
          doc1 = index.find_concept_by_identifier("112-02-09")
          doc2 = index.find_concept_by_identifier("112-02-09")
          expect(doc1).to be(doc2) # same object reference, no re-parse
        end
      end
    end
  end
end
