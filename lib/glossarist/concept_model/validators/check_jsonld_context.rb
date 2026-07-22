# frozen_string_literal: true

require "rdf/turtle"
require "json"

module Glossarist
  module ConceptModel
    module Validators
      # CheckJsonldContext — cross-checks ontology properties vs
      # JSON-LD context entries.
      #
      # For every owl:ObjectProperty / owl:DatatypeProperty in
      # glossarist.ttl, the JSON-LD context must contain a term
      # mapping to it.
      class CheckJsonldContext < Glossarist::ConceptModel::Validator
        GLOSS_PREFIX       = "https://www.glossarist.org/ontologies/".freeze
        OWL_OBJECT_PROP    = RDF::URI("http://www.w3.org/2002/07/owl#ObjectProperty").freeze
        OWL_DATATYPE_PROP  = RDF::URI("http://www.w3.org/2002/07/owl#DatatypeProperty").freeze

        def run
          onto_props = ontology_property_names
          ctx_terms  = context_terms
          missing    = onto_props - ctx_terms

          if missing.empty?
            ok("OK: all #{onto_props.length} ontology properties have JSON-LD context entries")
          else
            fail_with(
              "FAIL: #{missing.length} ontology properties missing from JSON-LD context",
              missing.sort.map { |m| "gloss:#{m}" },
            )
          end
        end

        private

        def ontology_property_names
          graph = RDF::Repository.new
          RDF::Reader.open(Repo::ONTOLOGY.to_s) { |r| r.each_statement { |s| graph << s } }
          props = Set.new
          [OWL_OBJECT_PROP, OWL_DATATYPE_PROP].each do |type|
            graph.query([nil, RDF.type, type]).each do |stmt|
              iri = stmt.subject.to_s
              props << iri.sub(%r{.*/}, "") if iri.start_with?(GLOSS_PREFIX)
            end
          end
          props
        end

        def context_terms
          ctx = JSON.parse(File.read(Repo::ROOT.join("ontologies/glossarist.context.jsonld")))["@context"]
          terms = Set.new
          ctx.each do |key, value|
            next if key.start_with?("@")
            iri = value.is_a?(Hash) ? value["@id"] : value
            terms << iri.sub("gloss:", "") if iri.is_a?(String) && iri.start_with?("gloss:")
          end
          terms
        end
      end
    end
  end
end
