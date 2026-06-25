# frozen_string_literal: true

# Glossarist::ConceptModel — Ruby surface for the canonical concept-model artifacts.
#
# Loads the generated PRED constants module and exposes a path resolver for
# the shipped ontology/context/shapes/schema files.

module Glossarist
  module ConceptModel
    class Error < StandardError; end

    ROOT = File.expand_path("../../..", __dir__)

    # Public: Absolute path to a shipped artifact.
    #
    # Example:
    #   Glossarist::ConceptModel.path("ontologies/glossarist.ttl")
    #   Glossarist::ConceptModel.path("ontologies/shapes/glossarist.shacl.ttl")
    #   Glossarist::ConceptModel.path("schemas/v3/concept.yaml")
    def self.path(relative)
      full = File.join(ROOT, relative)
      raise Error, "Unknown concept-model artifact: #{relative}" unless File.exist?(full)
      full
    end

    # Public: The version of the concept-model package, matching RubyGems.
    def self.version
      VERSION
    end
  end
end

require_relative "concept_model/version"
require_relative "concept_model/predicates"
