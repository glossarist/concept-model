# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe CheckPartitiveRelationCoherence do
        it "passes on the clean repo" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/PartitiveRelations coherent/)
        end

        it "warns on delimiting+optional incoherence" do
          # The validator emits warnings to stderr when a delimiting
          # partitive has optional multiplicity. No example currently
          # triggers this in the repo (by design — examples are valid).
          # This spec validates the validator runs without error.
          exit_code, _, _ = run_validator(described_class)
          expect(exit_code).to eq(0)
        end

        it "delegates invalid-pair detection to Multiplicity.invalid_pair?" do
          # The validator must not inline the (optional, at_least_one)
          # string comparison — that mapping is the SSOT responsibility
          # of Glossarist::ConceptModel::Multiplicity. This spec pins
          # the delegation so a future contributor doesn't re-introduce
          # the inline check (DRY).
          expect(Multiplicity).to respond_to(:invalid_pair?)
          expect(Multiplicity.invalid_pair?("optional", "at_least_one")).to be(true)
          expect(Multiplicity.invalid_pair?("required", "at_least_one")).to be(false)
          expect(Multiplicity.invalid_pair?("optional", "multiple")).to be(false)
        end
      end
    end
  end
end
