# 01 — glossarist-ruby: Add `sourced_from` to ConceptSource

## Context

The concept-model now defines `sourced_from` on `ConceptSource` as an array of
`Citation` objects, representing the upstream documents a lineage source was
itself sourced from. The concept-model schemas, ontology, SHACL shapes, and
JSON-LD context have been updated.

## Changes

### 1. Base class: `lib/glossarist/concept_source.rb`

Add `sourced_from` attribute (array of `Citation`) and its key_value mapping:

```ruby
attribute :sourced_from, Citation, collection: true

key_value do
  map :sourced_from, to: :sourced_from
  # ... existing maps
end
```

### 2. V2 override: `lib/glossarist/v2/concept_source.rb`

Override `sourced_from` to use `V2::Citation`:

```ruby
attribute :sourced_from, V2::Citation, collection: true

key_value do
  map :sourced_from, to: :sourced_from
  # ... existing maps
end
```

### 3. V3 override: `lib/glossarist/v3/concept_source.rb`

Override `sourced_from` to use `V3::Citation`:

```ruby
attribute :sourced_from, V3::Citation, collection: true

key_value do
  map :sourced_from, to: :sourced_from
  # ... existing maps
end
```

### 4. RDF emitter: `lib/glossarist/rdf/gloss_concept_source.rb`

Emit `gloss:sourcedFrom` triples for each `sourced_from` Citation, pointing to
the Citation resource (same pattern as `gloss:sourceOrigin`).

### 5. Tests: `spec/unit/concept_source_spec.rb`

Add tests for:
- `sourced_from` defaults to empty collection
- `sourced_from` round-trips through YAML with one Citation
- `sourced_from` round-trips through YAML with multiple Citations
- `sourced_from` works with V3 structured Citation::Ref

## Validation

```sh
cd /Users/mulgogi/src/glossarist/glossarist-ruby
bundle exec rspec spec/unit/concept_source_spec.rb
bundle exec rubocop lib/glossarist/concept_source.rb lib/glossarist/v2/concept_source.rb lib/glossarist/v3/concept_source.rb
```
