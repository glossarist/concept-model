# frozen_string_literal: true

require "spec_helper"
require "rdf/turtle"
require "tmpdir"

module Glossarist
  module ConceptModel
    RSpec.describe ShaclGenerator do
      # The generator renders from the live repo SSOTs. No doubles.
      let(:generator) { described_class.new }

      def load_graph(path)
        RDF::Graph.load(path)
      end

      describe "#render" do
        it "produces output that parses as Turtle" do
          rendered = generator.render
          expect { load_graph_from_string(rendered) }.not_to raise_error
        end

        it "is deterministic — two renders are byte-identical" do
          expect(generator.render).to eq(described_class.new.render)
        end

        it "renders every shape declared in shacl-model.yml" do
          model = YAML.safe_load_file(ShaclGenerator::MODEL_PATH, aliases: true)
          declared = model.fetch("shapes").keys.map { |n| "https://www.glossarist.org/ontologies/#{n}" }
          graph = load_graph_from_string(generator.render)
          type = RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
          node_shape = RDF::URI("http://www.w3.org/ns/shacl#NodeShape")
          rendered = graph.query([nil, type, node_shape]).map(&:subject).map(&:to_s)

          expect(rendered).to contain_exactly(*declared)
        end

        it "covers every glossarist.ttl owl:Class with a sh:targetClass" do
          onto = load_graph(Glossarist::ConceptModel::Repo::ONTOLOGY.to_s)
          owl_class = RDF::URI("http://www.w3.org/2002/07/owl#Class")
          gloss_prefix = "https://www.glossarist.org/ontologies/"
          classes = onto.query([nil, RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), owl_class])
                        .map(&:subject).map(&:to_s)
                        .select { |s| s.start_with?(gloss_prefix) }

          generated = load_graph_from_string(generator.render)
          target_class = RDF::URI("http://www.w3.org/ns/shacl#targetClass")
          targeted = generated.query([nil, target_class, nil]).map { |s| s.object.to_s }

          expect(classes - targeted).to be_empty
        end

        it "derives OWL properties into the shapes of their rdfs:domain classes" do
          generated = load_graph_from_string(generator.render)
          path = RDF::URI("http://www.w3.org/ns/shacl#path")
          geographical = RDF::URI("https://www.glossarist.org/ontologies/geographicalArea")
          shaped = generated.query([nil, path, geographical]).count

          expect(shaped).to be >= 1
        end

        it "emits every shape found in the committed file" do
          committed = load_graph(Glossarist::ConceptModel::Repo::SHACL.to_s)
          generated = load_graph_from_string(generator.render)
          type = RDF::URI("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
          node_shape = RDF::URI("http://www.w3.org/ns/shacl#NodeShape")

          committed_shapes = committed.query([nil, type, node_shape]).map { |s| s.subject.to_s }.sort
          generated_shapes = generated.query([nil, type, node_shape]).map { |s| s.subject.to_s }.sort

          expect(generated_shapes).to eq(committed_shapes)
        end
      end

      describe "#run" do
        it "succeeds in check mode against the committed file" do
          # The committed file must be exactly what the SSOTs render.
          expect(File.read(Repo::SHACL.to_s)).to eq(generator.render)
        end

        it "reports drift when the committed file differs from the render" do
          Dir.mktmpdir do |dir|
            output = File.join(dir, "drifted.ttl")
            File.write(output, "# stale content\n")

            gen = described_class.new(check_mode: true, output: output)
            code = nil
            swallow_streams { code = gen.run }

            expect(code).to eq(1)
          end
        end

        it "writes the rendered file and returns 0 in write mode" do
          Dir.mktmpdir do |dir|
            output = File.join(dir, "out.ttl")

            gen = described_class.new(output: output)
            code = nil
            swallow_streams { code = gen.run }

            expect(code).to eq(0)
            expect(File.read(output)).to eq(generator.render)
          end
        end
      end

      describe "constraint model integrity" do
        it "declares every section shape in shapes" do
          model = YAML.safe_load_file(ShaclGenerator::MODEL_PATH, aliases: true)
          declared = model.fetch("shapes").keys
          sectioned = model.fetch("sections").flat_map { |s| s.fetch("shapes") }

          expect(sectioned).to contain_exactly(*declared)
        end

        it "reports YAML-declared gloss paths missing from glossarist.ttl as warnings" do
          warnings = described_class.new.warnings_after_render
          expect(warnings).to all(include("not declared in glossarist.ttl"))
        end
      end

      private

      def load_graph_from_string(turtle)
        graph = RDF::Graph.new
        RDF::Turtle::Reader.new(turtle) { |reader| reader.each_statement { |s| graph << s } }
        graph
      end

      def swallow_streams
        original_out = $stdout
        original_err = $stderr
        $stdout = StringIO.new
        $stderr = StringIO.new
        yield
      ensure
        $stdout = original_out
        $stderr = original_err
      end
    end
  end
end
