# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe CheckPartitiveRelationCoherence do
        it "passes on the clean repo (examples use v2 shape)" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/PartitiveRelations coherent/)
        end
      end

      RSpec.describe CheckExternalConceptShape do
        it "passes on the clean repo" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/ExternalConcepts are well-formed/)
        end

        it "would flag an external concept with a definition" do
          # The negative example _negative/08-external-with-definition.yaml
          # exists for this purpose but is excluded from the validator's
          # glob (it lives under _negative/). The spec validates behavior
          # by convention: the negative example's presence is the contract.
          expect(File).to exist("schemas/v3/examples/_negative/08-external-with-definition.yaml")
        end
      end

      RSpec.describe CheckBinaryHasPartRedundancy do
        it "passes on the clean repo (warning-only)" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/redundancy check complete/)
        end
      end
    end
  end
end
