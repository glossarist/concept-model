# frozen_string_literal: true

module Glossarist
  module ConceptModel
    # Validators namespace. Autoloads each concrete validator.
    module Validators
      autoload :ValidateOntologies,            "glossarist/concept_model/validators/validate_ontologies"
      autoload :ValidateExamples,              "glossarist/concept_model/validators/validate_examples"
      autoload :ValidateNegativeExamples,      "glossarist/concept_model/validators/validate_negative_examples"
      autoload :CheckEnumDrift,                "glossarist/concept_model/validators/check_enum_drift"
      autoload :CheckJsonldContext,             "glossarist/concept_model/validators/check_jsonld_context"
      autoload :CheckShaclCoverage,             "glossarist/concept_model/validators/check_shacl_coverage"
      autoload :CheckLutamlReferences,          "glossarist/concept_model/validators/check_lutaml_references"
      autoload :CheckPartitiveRelationCoherence, "glossarist/concept_model/validators/check_partitive_relation_coherence"
      autoload :CheckExternalConceptShape,      "glossarist/concept_model/validators/check_external_concept_shape"
      autoload :CheckBinaryHasPartRedundancy,   "glossarist/concept_model/validators/check_binary_has_part_redundancy"
    end
  end
end
