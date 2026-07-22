# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    RSpec.describe Repo do
      it "exposes canonical paths under the gem root" do
        expect(described_class::ROOT).to be_a(Pathname)
        expect(described_class::ROOT).to exist
      end

      it "points at the canonical ontology file" do
        expect(described_class::ONTOLOGY.to_s).to end_with("ontologies/glossarist.ttl")
        expect(described_class::ONTOLOGY).to exist
      end

      it "points at the SHACL shapes file" do
        expect(described_class::SHACL.to_s).to end_with("ontologies/shapes/glossarist.shacl.ttl")
        expect(described_class::SHACL).to exist
      end

      it "points at the concept schema" do
        expect(described_class::CONCEPT_SCHEMA.to_s).to end_with("schemas/v3/concept.yaml")
        expect(described_class::CONCEPT_SCHEMA).to exist
      end

      it "exposes the EXTERNAL_LUTAML_TYPES allowlist" do
        expect(described_class::EXTERNAL_LUTAML_TYPES).to include("LocalizedString", "String")
      end
    end
  end
end
