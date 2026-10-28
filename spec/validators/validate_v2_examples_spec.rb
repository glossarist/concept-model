# frozen_string_literal: true

require "spec_helper"
require "yaml"
require "json_schemer"
require "tmpdir"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe "v2 example validation" do
        let(:schema_dir) { Repo::ROOT / "schemas/v2" }
        let(:concept_schema) { YAML.load_file(schema_dir / "concept.yaml") }
        let(:localized_schema) { YAML.load_file(schema_dir / "localized-concept.yaml") }

        it "uses valid JSON Schemas" do
          [concept_schema, localized_schema].each do |schema|
            expect(JSONSchemer.valid_schema?(schema)).to be(true)
          end
        end

        it "accepts structured related-concept references and preserves string references" do
          schema = concept_schema.fetch("$defs").fetch("related_concept")
          schemer = JSONSchemer.schema(schema)
          expect(schemer.valid?({ "ref" => { "source" => "IEC", "id" => "60050-702", "version" => "1988" } })).to be(true)
          expect(schemer.valid?({ "ref" => "702-01-01" })).to be(true)
          expect(schemer.valid?({ "ref" => 123 })).to be(false)
        end

        it "accepts lifecycle dates with or without time and rejects malformed dates" do
          schema = concept_schema.fetch("$defs").fetch("concept_date").fetch("properties").fetch("date")
          schemer = JSONSchemer.schema(schema)
          expect(schemer.valid?("1992-03-01T00:00:00+00:00")).to be(true)
          expect(schemer.valid?("1992-03-01")).to be(true)
          expect(schemer.valid?("not-a-date")).to be(false)
        end

        it "accepts locality objects and validates their fields" do
          schema = localized_schema.fetch("$defs").fetch("locality")
          schemer = JSONSchemer.schema(schema)
          expect(schemer.valid?({ "type" => "clause", "reference_from" => "3.3.3", "reference_to" => "3.3.5" })).to be(true)
          expect(schemer.valid?({ "type" => "locality:custom_1", "reference_from" => "A" })).to be(true)
          expect(schemer.valid?({ "type" => "invalid" })).to be(false)
          expect(schemer.valid?({ "reference_from" => 3 })).to be(false)
        end

        it "validates and lists every repository v2 example" do
          exit_code, stdout, stderr = run_validator(ValidateV2Examples)
          expect(exit_code).to eq(0), stderr
          files = Dir[schema_dir / "examples/**/*.yaml"]
          files.each do |path|
            expect(stdout).to include(File.basename(path))
          end
          expect(stdout).to include("#{files.length} v2 example files validated")
        end

        it "fails with the file and document location for an invalid example" do
          Dir.mktmpdir("v2-examples") do |dir|
            File.write(File.join(dir, "invalid.yaml"), "data:\n  language_code: eng\nstatus: invalid\n")
            result = ValidateV2Examples.new(examples_dir: dir).run
            expect(result.success?).to be(false)
            expect(result.details.join).to include("invalid.yaml", "doc 0", "/status")
          end
        end

        it "fails when no examples are present" do
          Dir.mktmpdir("v2-examples") do |dir|
            result = ValidateV2Examples.new(examples_dir: dir).run
            expect(result.success?).to be(false)
          end
        end
      end
    end
  end
end
