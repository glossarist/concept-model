# frozen_string_literal: true

require "spec_helper"

module Glossarist
  module ConceptModel
    RSpec.describe Validator do
      describe ".call and #call" do
        let(:subclass_ok) do
          Class.new(described_class) do
            def run = ok("good")
          end
        end

        let(:subclass_fail) do
          Class.new(described_class) do
            def run = fail_with("bad", %w[thing1 thing2])
          end
        end

        let(:subclass_raise) do
          Class.new(described_class) do
            def run = raise(StandardError, "kaboom")
          end
        end

        it "prints OK to stdout and exits 0 when result succeeds" do
          stdout = StringIO.new
          $stdout = stdout
          exit_code = subclass_ok.new.call
          $stdout = STDOUT
          expect(exit_code).to eq(0)
          expect(stdout.string).to eq("good\n")
        end

        it "prints failure details to stderr and exits 1 when result fails" do
          stderr = StringIO.new
          $stderr = stderr
          exit_code = subclass_fail.new.call
          $stderr = STDERR
          expect(exit_code).to eq(1)
          expect(stderr.string).to include("bad")
          expect(stderr.string).to include("thing1")
        end

        it "returns exit code 2 on unhandled exception" do
          stderr = StringIO.new
          $stderr = stderr
          exit_code = subclass_raise.new.call
          $stderr = STDERR
          expect(exit_code).to eq(2)
          expect(stderr.string).to include("ERROR")
          expect(stderr.string).to include("kaboom")
        end
      end

      describe Validator::Result do
        it "is a Struct with success, message, and details members" do
          expect(described_class.members).to include(:success, :message, :details)
        end
      end
    end
  end
end
