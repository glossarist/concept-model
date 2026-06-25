# frozen_string_literal: true

require_relative "lib/glossarist/concept_model/version"

Gem::Specification.new do |spec|
  spec.name          = "glossarist-concept-model"
  spec.version       = Glossarist::ConceptModel::VERSION
  spec.authors       = ["Glossarist Contributors"]
  spec.email         = ["open-source@glossarist.org"]
  spec.summary       = "Canonical SSOT for the Glossarist concept model: OWL ontology, JSON-LD context, SHACL shapes, and generated predicate constants."
  spec.description   = "Ships the Glossarist ontology (OWL), JSON-LD context, SHACL shapes, and YAML schemas as Ruby-consumable artifacts, plus a generated PRED constants module. Used by glossarist-ruby and any Ruby consumer of Glossarist data."
  spec.homepage      = "https://glossarist.org"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.metadata = {
    "homepage_uri"    => spec.homepage,
    "source_code_uri" => "https://github.com/glossarist/concept-model",
    "changelog_uri"   => "https://github.com/glossarist/concept-model/blob/main/CHANGELOG.md"
  }

  spec.files = Dir.glob("{lib,ontologies,schemas}/**/*").select { |f| File.file?(f) } +
    %w[README.md LICENSE]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
