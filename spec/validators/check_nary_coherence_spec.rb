# frozen_string_literal: true

require "spec_helper"
require "glossarist/concept_model/validators/check_generic_relation_coherence"
require "glossarist/concept_model/validators/check_partitive_relation_coherence"
require "glossarist/concept_model/validators/check_relation_file_shape"
require "glossarist/concept_model/validators/check_external_as_comprehensive"
require "glossarist/concept_model/validators/nary_coherence"

module Glossarist
  module ConceptModel
    module Validators
      RSpec.describe NaryCoherence do
        let(:test_class) do
          Class.new(Glossarist::ConceptModel::Validator) do
            include NaryCoherence

            attr_reader :collected

            def initialize(relations)
              @collected = relations
            end

            def each_relation
              @collected.each { |path, comp_id, rel| yield(path, comp_id, rel) }
            end

            def relative(path)
              path
            end
          end
        end

        it "flags relations with fewer than 2 members" do
          validator = test_class.new([
            ["f1", "X:1", { "members" => [{ "ref" => {} }] }]
          ])
          failures, = validator.run_coherence_checks("TestRelation")
          expect(failures.any? { |f| f.include?("TestRelation 0 has 1 members") }).to be true
        end

        it "flags duplicate (comprehensive, criterion) pairs" do
          validator = test_class.new([
            ["f1", "X:1", { "members" => [{ "ref" => {} }, { "ref" => {} }],
                             "criterion" => { "eng" => "by type" } }],
            ["f2", "X:1", { "members" => [{ "ref" => {} }, { "ref" => {} }],
                             "criterion" => { "eng" => "by type" } }]
          ])
          failures, = validator.run_coherence_checks("TestRelation")
          expect(failures.any? { |f| f.include?("duplicates") }).to be true
        end

        it "warns on missing criterion when sibling relations exist" do
          validator = test_class.new([
            ["f1", "X:1", { "members" => [{ "ref" => {} }, { "ref" => {} }],
                             "criterion" => { "eng" => "by type" } }],
            ["f2", "X:1", { "members" => [{ "ref" => {} }, { "ref" => {} }] }]
          ])
          _, warnings = validator.run_coherence_checks("TestRelation")
          expect(warnings.any? { |w| w.include?("no criterion") }).to be true
        end

        it "flags invalid MECE combinations" do
          validator = test_class.new([
            ["f1", "X:1", {
              "members" => [
                { "ref" => {}, "presence" => "optional", "count" => "at_least_one" },
                { "ref" => {} }
              ]
            }]
          ])
          failures, = validator.run_coherence_checks("TestRelation")
          expect(failures.any? { |f| f.include?("invalid;") }).to be true
        end

        it "warns when a delimiting member is optional" do
          validator = test_class.new([
            ["f1", "X:1", {
              "members" => [
                { "ref" => {}, "is_delimiting" => true, "presence" => "optional" },
                { "ref" => {} }
              ]
            }]
          ])
          _, warnings = validator.run_coherence_checks("TestRelation")
          expect(warnings.any? { |w| w.include?("delimiting but optional") }).to be true
        end

        it "accepts well-formed relations" do
          validator = test_class.new([
            ["f1", "X:1", {
              "members" => [
                { "ref" => {} },
                { "ref" => {} }
              ],
              "criterion" => { "eng" => "by type" }
            }]
          ])
          failures, warnings = validator.run_coherence_checks("TestRelation")
          expect(failures).to be_empty
          expect(warnings).to be_empty
        end
      end

      RSpec.describe CheckGenericRelationCoherence do
        it "runs and returns a Result" do
          result = described_class.call
          expect(result).to satisfy { |r| r == 0 || r == 1 }
        end
      end

      RSpec.describe CheckPartitiveRelationCoherence do
        it "runs and returns a Result" do
          result = described_class.call
          expect(result).to satisfy { |r| r == 0 || r == 1 }
        end
      end

      RSpec.describe CheckRelationFileShape do
        it "runs and returns a Result" do
          result = described_class.call
          expect(result).to satisfy { |r| r == 0 || r == 1 }
        end
      end

      RSpec.describe CheckExternalAsComprehensive do
        it "runs and returns a Result" do
          result = described_class.call
          expect(result).to satisfy { |r| r == 0 || r == 1 }
        end
      end
    end
  end
end
