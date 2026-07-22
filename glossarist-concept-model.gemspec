# frozen_string_literal: true

require_relative "lib/glossarist/concept_model/version"

Gem::Specification.new do |spec|
  spec.name          = "glossarist-concept-model"
  spec.version       = Glossarist::ConceptModel::VERSION
  spec.summary       = "Glossarist concept-model — model-driven terminological schema, ontology, shapes, and validators."
  spec.description   = <<~DESC
    The concept-model repository is the source of truth for the Glossarist
    data model: LUTAML classes, JSON Schemas, OWL ontology, SHACL shapes,
    SKOS taxonomies, and a JSON-LD context. Pure-Ruby validators under
    lib/glossarist/concept_model keep the layers in sync via CI.
  DESC
  spec.authors       = ["Glossarist maintainers"]
  spec.homepage      = "https://github.com/glossarist/concept-model"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob("{lib,exe,models,schemas,ontologies,docs}/**/*") +
      %w[CHANGELOG.md README.adoc CONTRIBUTING.md ARCHITECTURE.md]
  end
  spec.bindir        = "exe"
  spec.executables   = Dir.glob("exe/*").map { |p| File.basename(p) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "rdf", "~> 3.3"
  spec.add_dependency "rdf-turtle", "~> 3.3"
  spec.add_dependency "json_schemer", "~> 2.5"

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rake", "~> 13.0"
end
