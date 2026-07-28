# frozen_string_literal: true

require "spec_helper"
require "glossarist/concept_model/multiplicity"

module Glossarist
  module ConceptModel
    RSpec.describe Multiplicity do
      describe ".from_pair" do
        it "maps all 5 valid pairs to ISO 704 names" do
          expect(described_class.from_pair("required", "exactly_one")).to eq("compulsory")
          expect(described_class.from_pair("optional", "exactly_one")).to eq("optional")
          expect(described_class.from_pair("required", "multiple")).to eq("compulsory_multiple")
          expect(described_class.from_pair("optional", "multiple")).to eq("optional_multiple")
          expect(described_class.from_pair("required", "at_least_one")).to eq("compulsory_at_least_one")
        end

        it "raises on the invalid (optional, at_least_one) pair" do
          expect { described_class.from_pair("optional", "at_least_one") }
            .to raise_error(ArgumentError, /invalid.*pair/)
        end

        it "raises on unknown values" do
          expect { described_class.from_pair("maybe", "exactly_one") }
            .to raise_error(ArgumentError, /invalid.*pair/)
        end
      end

      describe ".to_pair" do
        it "maps ISO 704 names back to MECE pairs" do
          expect(described_class.to_pair("compulsory")).to eq(["required", "exactly_one"])
          expect(described_class.to_pair("optional")).to eq(["optional", "exactly_one"])
          expect(described_class.to_pair("compulsory_multiple")).to eq(["required", "multiple"])
          expect(described_class.to_pair("optional_multiple")).to eq(["optional", "multiple"])
          expect(described_class.to_pair("compulsory_at_least_one")).to eq(["required", "at_least_one"])
        end

        it "raises on unknown names" do
          expect { described_class.to_pair("bogus") }.to raise_error(ArgumentError, /unknown/)
        end
      end

      describe ".invalid_pair?" do
        it "returns true for the invalid combination" do
          expect(described_class.invalid_pair?("optional", "at_least_one")).to be true
        end

        it "returns false for all 5 valid combinations" do
          expect(described_class.invalid_pair?("required", "exactly_one")).to be false
          expect(described_class.invalid_pair?("optional", "exactly_one")).to be false
          expect(described_class.invalid_pair?("required", "multiple")).to be false
          expect(described_class.invalid_pair?("optional", "multiple")).to be false
          expect(described_class.invalid_pair?("required", "at_least_one")).to be false
        end
      end

      describe ".valid_pair?" do
        it "returns true for all 5 valid combinations" do
          expect(described_class.valid_pair?("required", "exactly_one")).to be true
          expect(described_class.valid_pair?("optional", "exactly_one")).to be true
          expect(described_class.valid_pair?("required", "multiple")).to be true
          expect(described_class.valid_pair?("optional", "multiple")).to be true
          expect(described_class.valid_pair?("required", "at_least_one")).to be true
        end

        it "returns false for the invalid combination" do
          expect(described_class.valid_pair?("optional", "at_least_one")).to be false
        end
      end
    end

    RSpec.describe "MECE example coverage" do
      it "covers all 5 valid presence/count combinations in examples" do
        combos_seen = Set.new
        Dir.glob("schemas/v3/examples/{2,3}*.yaml").sort.each do |f|
          YAML.load_stream(File.read(f)).each do |doc|
            next unless doc.is_a?(Hash) && doc["partitive_relations"]
            doc["partitive_relations"].each do |rel|
              (rel["partitives"] || []).each do |p|
                # Collect ALL members including defaults (when neither
                # presence nor count is explicitly set, defaults apply:
                # required + exactly_one).
                combos_seen << [p["presence"] || "required", p["count"] || "exactly_one"]
              end
            end
          end
        end
        expect(combos_seen).to include(["required", "exactly_one"])
        expect(combos_seen).to include(["optional", "exactly_one"])
        expect(combos_seen).to include(["required", "multiple"])
        expect(combos_seen).to include(["optional", "multiple"])
        expect(combos_seen).to include(["required", "at_least_one"])
        expect(combos_seen).not_to include(["optional", "at_least_one"])
      end
    end
  end
end
