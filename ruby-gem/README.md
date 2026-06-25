# glossarist-concept-model

Canonical Ruby surface for the Glossarist concept model.

This gem ships the generated `Glossarist::ConceptModel::PRED` constants
module (mirroring `@glossarist/concept-model` on npm) plus accessor methods
for the canonical ontology, JSON-LD context, SHACL shapes, and YAML schemas
that live in the parent directory.

## Usage

```ruby
require "glossarist/concept_model"

Glossarist::ConceptModel::PRED::GLOSS.fetch(:has_definition)
# => "https://www.glossarist.org/ontologies/hasDefinition"

Glossarist::ConceptModel::PRED::SKOS.fetch(:pref_label)
# => "http://www.w3.org/2004/02/skos/core#prefLabel"

Glossarist::ConceptModel::PRED::PREFIXES.fetch("skosxl")
# => "http://www.w3.org/2008/05/skos-xl#"

Glossarist::ConceptModel.path("ontologies/glossarist.ttl")
# => /path/to/glossarist-concept-model-0.1.0/ontologies/glossarist.ttl
```

## Source

The canonical artifacts live in the [glossarist/concept-model](https://github.com/glossarist/concept-model)
monorepo. The `predicates.rb` file is generated from `ontologies/glossarist.context.jsonld`
by `scripts/gen-predicates.mjs` and synced here by `rake gen`.
