# frozen_string_literal: true

require "spec_helper"

RSpec.describe Glossarist::ConceptModel do
  it "exposes a version string" do
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end

  it "exposes the predicate constants module" do
    expect(described_class::PRED::GLOSS).to include(
      has_definition: "https://www.glossarist.org/ontologies/hasDefinition"
    )
    expect(described_class::PRED::SKOS).to include(
      pref_label: "http://www.w3.org/2004/02/skos/core#prefLabel"
    )
    expect(described_class::PRED::SKOSXL).to include(
      literal_form: "http://www.w3.org/2008/05/skos-xl#literalForm"
    )
  end

  it "preserves class URIs alongside predicate URIs within a namespace" do
    expect(described_class::PRED::GLOSS).to include(
      Concept: "https://www.glossarist.org/ontologies/Concept"
    )
  end

  it "exposes a prefix map with string keys" do
    prefixes = described_class::PRED::PREFIXES
    expect(prefixes).to include("skosxl" => "http://www.w3.org/2008/05/skos-xl#")
    expect(prefixes).to include("gloss" => "https://www.glossarist.org/ontologies/")
    expect(prefixes.keys).to all(be_a(String))
  end

  describe ".path" do
    it "resolves shipped artifacts" do
      ttl = described_class.path("ontologies/glossarist.ttl")
      expect(File.exist?(ttl)).to be(true)
    end

    it "raises for unknown artifacts" do
      expect { described_class.path("does/not/exist") }.to raise_error(described_class::Error)
    end
  end
end
