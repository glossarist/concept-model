# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe CheckEnumDrift do
        it "passes on the clean repo" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/OK: \d+ taxonomies/)
        end
      end

      RSpec.describe CheckJsonldContext do
        it "covers every ontology property" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/all \d+ ontology properties/)
        end
      end

      RSpec.describe CheckShaclCoverage do
        it "shapes every ontology class" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/all \d+ ontology classes have SHACL shapes/)
        end
      end

      RSpec.describe CheckLutamlReferences do
        it "resolves all LUTAML class references" do
          exit_code, stdout, = run_validator(described_class)
          expect(exit_code).to eq(0), stderr_message(stdout)
          expect(stdout).to match(/all class references resolve/)
        end
      end
    end
  end
end
