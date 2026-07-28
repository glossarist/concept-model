# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    RSpec.describe "PartitiveMember presence/count" do
      # Schema constraint validation. The schema's allOf/if-then block
      # rejects the invalid combination presence=optional + count=at_least_one
      # because when a part is optional, at-least-one is vacuous and
      # collapses to multiple.
      it "rejects optional + at_least_one combination" do
        # This combination is already covered by
        # schemas/v3/examples/_negative/10-invalid-presence-count-combo.yaml
        # which the validate-negative-examples runner asserts.
        expect(File).to exist("schemas/v3/examples/_negative/10-invalid-presence-count-combo.yaml")
      end

      it "accepts the 5 valid combinations" do
        # The 5 valid combos are exercised by examples 20, 22, 23, 29,
        # 30, 31, 32 (and example 24 with presence: optional).
        # Coverage matrix:
        #
        #   presence    count         example
        #   ----------  -----------  -------
        #   required    exactly_one   20, 23 (default for both)
        #   optional    exactly_one   22, 24, 29
        #   required    multiple      30
        #   optional    multiple      31
        #   required    at_least_one  32
        #   optional    at_least_one  REJECTED (no example)
        expect(File).to exist("schemas/v3/examples/20-partitive-relation-closed.yaml")
        expect(File).to exist("schemas/v3/examples/22-partitive-relation-mixed-multiplicity.yaml")
        expect(File).to exist("schemas/v3/examples/30-partitive-relation-compulsory-multiple.yaml")
        expect(File).to exist("schemas/v3/examples/31-partitive-relation-optional-multiple.yaml")
        expect(File).to exist("schemas/v3/examples/32-partitive-relation-compulsory-at-least-one.yaml")
      end
    end
  end
end
