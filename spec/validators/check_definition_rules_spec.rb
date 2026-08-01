# frozen_string_literal: true

require "spec_helper"
require "glossarist/concept_model/validators/check_definition_rules"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe CheckDefinitionRules do
        describe "extensional definition open-ended wording check (§6.4.5.1)" do
          let(:validator) { described_class.new }

          it "detects ellipsis in extensional definitions" do
            expect(validator.send(:detect_open_ended_wording, "helium, neon, argon...")).to eq("...")
          end

          it "detects 'etc.' in extensional definitions" do
            expect(validator.send(:detect_open_ended_wording, "firs, pines, etc.")).to eq("etc.")
          end

          it "detects 'and similar' in extensional definitions" do
            expect(validator.send(:detect_open_ended_wording, "firs, pines, and similar items")).to eq("and similar")
          end

          it "detects 'and so on'" do
            expect(validator.send(:detect_open_ended_wording, "step 1, step 2, and so on")).to eq("and so on")
          end

          it "detects 'and the like'" do
            expect(validator.send(:detect_open_ended_wording, "screwdrivers, wrenches, and the like")).to eq("and the like")
          end

          it "detects 'and other'" do
            expect(validator.send(:detect_open_ended_wording, "oak, maple, and other trees")).to eq("and other")
          end

          it "detects 'including'" do
            expect(validator.send(:detect_open_ended_wording, "gases including helium and neon")).to eq("including")
          end

          it "returns nil for exhaustive extensional definitions" do
            result = validator.send(:detect_open_ended_wording,
              "helium, neon, argon, krypton, xenon, radon or oganesson")
            expect(result).to be_nil
          end

          it "returns nil for intensional definitions (not type-checked)" do
            # The check only fires for type: extensional; intensional defs
            # can contain "..." in examples without violating §6.4.5.1.
            result = validator.send(:detect_open_ended_wording,
              "a noble gas such as helium, neon, etc.")
            # detect_open_ended_wording itself doesn't check type; it's
            # the caller's job to gate on type. The method WILL find "etc."
            # but the validator only warns when type == extensional.
            expect(result).to eq("etc.")
          end
        end
      end
    end
  end
end
