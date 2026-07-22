# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe ValidateExamples do
        it "passes on the clean repo" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/OK: \d+ example files validated/)
        end
      end

      RSpec.describe ValidateNegativeExamples do
        it "rejects all curated negative examples (or skips documented gaps)" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/negative examples correctly rejected/)
        end
      end
    end
  end
end
