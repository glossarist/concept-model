# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe ValidateOntologies do
        it "passes on the clean repo" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/OK:/)
          expect(stdout).not_to match(/FAIL/)
        end

        it "detects malformed Turtle when given a broken file", :broken_turtle do
          pending "no hermetic fixture support yet — needs --repo-root flag"
          raise "not implemented"
        end
      end
    end
  end
end
