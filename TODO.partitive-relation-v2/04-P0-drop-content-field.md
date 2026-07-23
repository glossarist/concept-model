# 04 — P0: Drop `content` field from PartitiveRelation

## Problem

The shipped `PartitiveHyperedge.content` field (and the contributor's
later L10N-ification attempt) carried free-form text on the
relation. This conflates two distinct concerns:

1. **Type-level meaning** ("what a partitive relation IS") — this is
   global i18n, lives in the SKOS taxonomy
   (`ontologies/taxonomies/relationship-type.ttl`)
2. **Per-instance notes** ("what THIS specific decomposition is
   about") — these are notes, belong on LocalizedConcept or as
   separate caption structures

A graph edge is structural — it carries ConceptRefs and metadata
about the relation (completeness, plurality, certainty). It does
not carry prose. If a decomposition needs explanatory text, that
text belongs on the comprehensive concept (as a note) or as a
separate caption structure (Figure-style).

## Scope

- `models/concepts/PartitiveRelation.lutaml` — delete `+content`
- `schemas/v3/concept.yaml` — delete `content` property from
  `partitive_relation` $def
- `ontologies/glossarist.ttl` — delete `gloss:hyperedgeContent` and
  its aliases
- `ontologies/shapes/glossarist.shacl.ttl` — delete `hyperedgeContent`
  property shape
- `ontologies/glossarist.context.jsonld` — delete `hyperedgeContent`
- Examples — drop `content:` from examples 20, 21, 23

## Concrete changes

### LUTAML model

```ruby
class PartitiveRelation {
  # ...
  # DELETE: +content: <<BasicDocument>> LocalizedString [0..1]
  # (structural edges do not carry prose)
}
```

### Schema

```yaml
$defs:
  partitive_relation:
    properties:
      comprehensive: { ... }
      partitives: { ... }
      completeness: { ... }
      plurality: { ... }
      criterion: { ... }       # added in step 05
      # DELETE: content
```

### Ontology

```turtle
# DELETE this entire block from ontologies/glossarist.ttl:
# gloss:hyperedgeContent a owl:DatatypeProperty ;
#   rdfs:domain gloss:PartitiveRelation ;
#   ...
```

### SHACL

```turtle
gloss:PartitiveRelationShape a sh:NodeShape ;
  # ...
  # DELETE this sh:property block:
  # sh:property [
  #   sh:path gloss:hyperedgeContent ;
  #   sh:datatype xsd:string ;
  #   sh:maxCount 1 ;
  # ]
.
```

### JSON-LD context

```jsonld
// DELETE:
// "hyperedgeContent": { "@id": "gloss:hyperedgeContent", "@type": "xsd:string" },
```

### Examples

Examples 20, 21, 23 currently use `content:` on the hyperedge.
Drop the field. If the explanatory text is important, move it to
the comprehensive concept's `notes:` array.

```yaml
# Before (example 20):
partitive_hyperedges:
  - comprehensive: { source: VIM, id: "112-02-09" }
    parts: [ ... ]
    enumeration: closed
    markers: [double]
    content: |
      A measurement result is composed of a measured quantity value
      and a measurement uncertainty. No other components are part
      of the result.

# After (example 20):
partitive_relations:
  - comprehensive: { source: VIM, id: "112-02-09" }
    partitives:
      - ref: { source: VIM, id: "112-02-10" }
      - ref: { source: VIM, id: "112-03-26" }
    completeness: complete
    plurality:
      is_shared: true
    # content field removed
```

If the prose is valuable for the example, add it as a comment in
the YAML header (not as data).

## Verification

```bash
! grep -r "hyperedgeContent" models/ schemas/ ontologies/ docs/
! grep -E "^\s+content:" schemas/v3/examples/2*.yaml
make validate
```

## Migration

The `content` field on existing PartitiveHyperedge data is dropped
during migration. The text is preserved as a YAML comment in the
migrated file (reviewer decides whether to move it to the
comprehensive concept's notes).

See `08-P1-migration-script.md`.

## Downstream impact

- glossarist-ruby: `V3::PartitiveRelation` drops the `content`
  attribute. Specs referencing `hyperedge.content` need updates.
- glossarist-js: `PartitiveRelation` class drops `content`. Any UI
  displaying hyperedge content needs to find another source.
- concept-browser: `PartitiveHyperedgeList.vue` removes the content
  display block.

See `17-downstream-consumer-guide.md`.

## Status: pending
