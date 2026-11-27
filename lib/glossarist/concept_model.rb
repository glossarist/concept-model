# frozen_string_literal: true

module Glossarist
  module ConceptModel
    GEM_ROOT = File.expand_path("../..", __dir__)

    autoload :Repo,                "glossarist/concept_model/repo"
    autoload :Validator,           "glossarist/concept_model/validator"
    autoload :Multiplicity,        "glossarist/concept_model/multiplicity"
    autoload :ConceptIndex,        "glossarist/concept_model/concept_index"
    autoload :SchemaTypeGenerator, "glossarist/concept_model/schema_type_generator"
    autoload :ShaclGenerator,      "glossarist/concept_model/shacl_generator"
    autoload :Validators,          "glossarist/concept_model/validators"
  end
end
