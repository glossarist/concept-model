# frozen_string_literal: true

module Glossarist
  module ConceptModel
    GEM_ROOT = File.expand_path("../..", __dir__)

    autoload :Repo,      "glossarist/concept_model/repo"
    autoload :Validator, "glossarist/concept_model/validator"
    autoload :Validators, "glossarist/concept_model/validators"
  end
end
