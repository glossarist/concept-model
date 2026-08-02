# frozen_string_literal: true

module Glossarist
  module ConceptModel
    # Validators namespace. Autoloads each concrete validator.
    module Validators
      autoload :ValidateOntologies,             "glossarist/concept_model/validators/validate_ontologies"
      autoload :ValidateExamples,               "glossarist/concept_model/validators/validate_examples"
      autoload :ValidateNegativeExamples,       "glossarist/concept_model/validators/validate_negative_examples"
      autoload :CheckEnumDrift,                 "glossarist/concept_model/validators/check_enum_drift"
      autoload :CheckJsonldContext,             "glossarist/concept_model/validators/check_jsonld_context"
      autoload :CheckShaclCoverage,             "glossarist/concept_model/validators/check_shacl_coverage"
      autoload :CheckLutamlReferences,          "glossarist/concept_model/validators/check_lutaml_references"
      autoload :CheckPartitiveRelationCoherence, "glossarist/concept_model/validators/check_partitive_relation_coherence"
      autoload :CheckGenericRelationCoherence,  "glossarist/concept_model/validators/check_generic_relation_coherence"
      autoload :CheckSequentialRelationCoherence, "glossarist/concept_model/validators/check_sequential_relation_coherence"
      autoload :CheckRelationFileShape,         "glossarist/concept_model/validators/check_relation_file_shape"
      autoload :CheckExternalAsComprehensive,   "glossarist/concept_model/validators/check_external_as_comprehensive"
      autoload :CheckExternalConceptShape,      "glossarist/concept_model/validators/check_external_concept_shape"
      autoload :CheckBinaryHasPartRedundancy,   "glossarist/concept_model/validators/check_binary_has_part_redundancy"
      autoload :CheckDefinitionRules,           "glossarist/concept_model/validators/check_definition_rules"
      autoload :CheckBibliographyNotConceptIds, "glossarist/concept_model/validators/check_bibliography_not_concept_ids"
      autoload :CheckNoRawHtmlInConceptText,   "glossarist/concept_model/validators/check_no_raw_html_in_concept_text"
      autoload :NaryCoherence,                  "glossarist/concept_model/validators/nary_coherence"
    end
  end
end
