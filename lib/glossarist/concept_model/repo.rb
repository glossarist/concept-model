# frozen_string_literal: true

require "pathname"

module Glossarist
  module ConceptModel
    # Repo resolves the canonical paths for a concept-model checkout.
    # Single source of truth for path resolution across validators.
    module Repo
      ROOT = Pathname.new(GEM_ROOT).expand_path

      ONTOLOGY            = ROOT / "ontologies/glossarist.ttl"
      SHACL               = ROOT / "ontologies/shapes/glossarist.shacl.ttl"
      TAXONOMIES_DIR      = ROOT / "ontologies/taxonomies"
      ONTOLOGIES_DIR      = ROOT / "ontologies"
      SCHEMAS_DIR         = ROOT / "schemas/v3"
      CONCEPT_SCHEMA      = SCHEMAS_DIR / "concept.yaml"
      LOCALIZED_SCHEMA    = SCHEMAS_DIR / "localized-concept.yaml"
      REGISTER_SCHEMA     = SCHEMAS_DIR / "register.yaml"
      EXAMPLES_DIR        = SCHEMAS_DIR / "examples"
      NEGATIVE_EXAMPLES   = EXAMPLES_DIR / "_negative"
      MODELS_DIR          = ROOT / "models"

      # LUTAML "external" types — declared by the lutaml standard library
      # or by the project's lutaml-model extensions. Not defined in models/.
      EXTERNAL_LUTAML_TYPES = %w[
        LocalizedString
        ReferenceToTermbase
        ParagraphBlock
        TextElement
        TextElementType
        String
        Boolean
        Integer
        Iso8601Date
        Image
        LocalizedStringMap
        GlossaristTextElementType
      ].freeze

      # Schema choice per example file, by filename convention.
      # Mirrors the heuristic validators/validate_examples.rb uses.
      LOCALIZED_MARKERS = %w[
        localized
        designation-
        pronunciation
        term-types
        citation-features
        nonverbal
        multilanguage-
        absent-designation-
        definition-notes
      ].freeze

      REGISTER_MARKERS = %w[register].freeze
    end
  end
end
