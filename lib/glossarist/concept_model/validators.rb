# frozen_string_literal: true

module Glossarist
  module ConceptModel
    # Validators namespace. Autoloads each concrete validator.
    module Validators
      autoload :ValidateOntologies,        "glossarist/concept_model/validators/validate_ontologies"
      autoload :ValidateExamples,          "glossarist/concept_model/validators/validate_examples"
      autoload :ValidateNegativeExamples,  "glossarist/concept_model/validators/validate_negative_examples"
      autoload :CheckEnumDrift,            "glossarist/concept_model/validators/check_enum_drift"
      autoload :CheckJsonldContext,         "glossarist/concept_model/validators/check_jsonld_context"
      autoload :CheckShaclCoverage,         "glossarist/concept_model/validators/check_shacl_coverage"
      autoload :CheckLutamlReferences,      "glossarist/concept_model/validators/check_lutaml_references"
    end
  end
end
