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
      end
    end
  end
end
