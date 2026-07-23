# 16 — P2: Definition types (future, noted)

## Why this is noted, not implemented

ISO 12620 defines **definition types**:

- **extensional definition**: describes a concept by enumerating
  all of its subordinate concepts under one criterion of subdivision
- **intensional definition**: describes the intension of a concept
  by stating the superordinate concept and the delimiting
  characteristics
- **partitive definition**: based on the enumeration of the
  concepts that refer to the main parts of an object covered by a
  superordinate concept in a partitive relation
- **translated definition**: a definition that has been translated
  from another language

Our current `DetailedDefinition` model has no `type` field. This
is a gap, but orthogonal to PartitiveRelation.

## Why "partitive definition" matters here

A **partitive definition** is a *definition style* (defines a
concept by listing its parts). It is distinct from a
**PartitiveRelation** (asserts that one concept is composed of
others).

The two often co-occur: a concept with a partitive definition
typically also has a PartitiveRelation encoding the same
decomposition. But they serve different purposes:
- Partitive definition: text for human readers
- PartitiveRelation: structured data for tooling

## Proposed future model (sketch)

```ruby
class DetailedDefinition
  +content: LocalizedString [1..1]            # the definition text
  +type: DefinitionType [0..1]                # NEW
  +sources: ConceptSource [0..*]
end

enum DefinitionType
  intensional       # default; "X is a Y that..."
  extensional       # enumerates subordinate concepts
  partitive         # enumerates parts (companion to PartitiveRelation)
  translated        # translated from another language
```

## Verification approach (future)

- SHACL: `sh:valuesFrom <.../definitionType>` on the type property
- Taxonomy: new `ontologies/taxonomies/definition-type.ttl`
- Schema: new `definition_type` enum $def
- Validator: warn when a partitive definition exists without a
  companion PartitiveRelation (suggest linking)

## Trigger for implementation

When a real dataset needs to distinguish definition styles for
rendering or analysis. Not blocking for v2.

## Status: noted (P2 — not implemented in v2)
