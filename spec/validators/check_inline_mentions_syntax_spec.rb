# frozen_string_literal: true

require "spec_helper"
require "glossarist/concept_model/validators/check_inline_mentions_syntax"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe CheckInlineMentionsSyntax do
        let(:validator) { described_class.new }
        let(:location) { "test.yaml[doc 0]" }
        let(:field) { "definition" }
        let(:index) { 0 }

        describe "valid mentions (accepted)" do
          it "accepts concept with DATASET:ID" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "concept:IEV:702-02-07", failures)
            expect(failures).to be_empty
          end

          it "accepts concept with URN" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "concept:urn:iec:std:iec:60050:702-02-07", failures)
            expect(failures).to be_empty
          end

          it "accepts cite with DATASET:ID" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "cite:IEV:702-02-07", failures)
            expect(failures).to be_empty
          end

          it "accepts fig with plain ID" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "fig:diagram_3", failures)
            expect(failures).to be_empty
          end

          it "accepts fig with URN" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "fig:urn:iec:std:iec:60050:figure:diagram_3", failures)
            expect(failures).to be_empty
          end

          it "accepts bib with plain ID" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "bib:ref_1", failures)
            expect(failures).to be_empty
          end

          it "accepts link with https URL" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "link:https://example.com/page", failures)
            expect(failures).to be_empty
          end

          it "accepts link with http URL" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "link:http://example.com/page", failures)
            expect(failures).to be_empty
          end

          it "accepts image with path" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "image:figures/test.svg, Test figure", failures)
            expect(failures).to be_empty
          end

          it "accepts mentions with labels" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "concept:IEV:702-02-07, signal processing", failures)
            expect(failures).to be_empty
          end
        end

        describe "rejected mentions (magic combinations)" do
          it "rejects bare text without kind prefix" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "measurement unit", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/missing kind prefix/)
          end

          it "rejects bare numeric without kind prefix" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "112-01-10", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/missing kind prefix/)
          end

          it "rejects cite with bare local ID" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "cite:sourceId1", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/must be DATASET:ID or URN.*bare ID/)
          end

          it "rejects concept with bare ID (no dataset qualifier)" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "concept:112-01-10", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/must be DATASET:ID or URN.*bare ID/)
          end

          it "rejects link with non-URL target" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "link:/internal/path", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/must be https:\/\/ or http:\/\//)
          end

          it "rejects bib with URN" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "bib:urn:something", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/do not have URNs/)
          end

          it "rejects unknown kind" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "foo:bar", failures)
            expect(failures).not_to be_empty
            expect(failures.first).to match(/unknown kind/)
          end
        end

        describe "DATASET:ID colon splitting" do
          it "accepts source names with colons (split on last colon)" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "concept:ISO:10241-1:2011", failures)
            expect(failures).to be_empty
          end

          it "accepts URN with multiple colons" do
            failures = []
            validator.send(:validate_mention, location, field, index,
                           "cite:urn:iec:std:iec:60050:702-02-07", failures)
            expect(failures).to be_empty
          end
        end
      end
    end
  end
end
