# frozen_string_literal: true

require "rdf/turtle"

module Glossarist
  module ConceptModel
    module Validators
      # CheckShaclCoverage — every owl:Class in glossarist.ttl must
      # have a sh:NodeShape targeting it via sh:targetClass.
      class CheckShaclCoverage < Glossarist::ConceptModel::Validator
        GLOSS_PREFIX        = "https://www.glossarist.org/ontologies/".freeze
        OWL_CLASS           = RDF::URI("http://www.w3.org/2002/07/owl#Class").freeze
        SHACL_TARGET_CLASS  = RDF::URI("http://www.w3.org/ns/shacl#targetClass").freeze

        def run
          onto   = ontology_named_classes
          shaped = shaped_classes_set
          unshaped = onto - shaped

          if unshaped.empty?
            ok("OK: all #{onto.length} ontology classes have SHACL shapes")
          else
            fail_with(
              "FAIL: #{unshaped.length} ontology classes have no SHACL shape",
              unshaped.sort.map { |c| "gloss:#{c}" },
            )
          end
        end

        private

        def ontology_named_classes
          graph = read_graph(Repo::ONTOLOGY.to_s)
          acc = Set.new
          graph.query([nil, RDF.type, OWL_CLASS]).each do |stmt|
            iri = stmt.subject.to_s
            next unless iri.start_with?(GLOSS_PREFIX)
            acc << iri.sub(%r{.*/}, "")
          end
          acc
        end

        def shaped_classes_set
          graph = read_graph(Repo::SHACL.to_s)
          acc = Set.new
          graph.query([nil, SHACL_TARGET_CLASS, nil]).each do |stmt|
            iri = stmt.object.to_s
            next unless iri.start_with?(GLOSS_PREFIX)
            acc << iri.sub(%r{.*/}, "")
          end
          acc
        end

        def read_graph(path)
          repo = RDF::Repository.new
          RDF::Reader.open(path) { |r| r.each_statement { |s| repo << s } }
          repo
        end
      end
    end
  end
end
