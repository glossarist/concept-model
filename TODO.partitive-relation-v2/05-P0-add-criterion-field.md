# 05 — P0: Add `criterion: LocalizedString [0..1]` to PartitiveRelation

## Problem

ISO 12620 defines **coordinate concept** as:

> "A subordinate concept having the same nearest superordinate
> concept and **same criterion of subdivision** as some other
> concept in a given concept system."

Partitives within a PartitiveRelation are coordinate concepts. They
share the comprehensive (superordinate partitive) AND share a
criterion of subdivision.

Without modeling the criterion, two different decompositions of the
same comprehensive are indistinguishable:

- "bicycle decomposed by physical structure" → {frame, wheels,
  handlebar, seat, pedals, chain}
- "bicycle decomposed by functional subsystem" → {structural,
  propulsion, steering, braking}

Both have the same comprehensive (bicycle) and would appear as
duplicate PartitiveRelations if criterion isn't recorded.

## Scope

- `models/concepts/PartitiveRelation.lutaml` — add `+criterion`
- `schemas/v3/concept.yaml` — add `criterion` property
- `ontologies/glossarist.ttl` — add `gloss:criterion` property
- `ontologies/shapes/glossarist.shacl.ttl` — add criterion shape
- `ontologies/glossarist.context.jsonld` — add term
- Examples — add criterion to existing examples
- Validators — add coherence check

## Concrete changes

### LUTAML model

```ruby
class PartitiveRelation {
  # ...
  +criterion: <<BasicDocument>> LocalizedString [0..1] {
    definition {
      The principle by which the comprehensive is divided into
      partitives. ISO 12620: partitives within one relation are
      coordinate concepts — they share the comprehensive AND
      share the criterion of subdivision.

      Optional in v1 (most existing data won't have one). When
      present, two PartitiveRelations on the same comprehensive
      with the same criterion are duplicates (validation error).
      Two with different criteria are distinct decompositions.

      Multilingual (concept-level metadata). Examples:
        - "physical structure"
        - "functional subsystem"
        - "temporal phases"
        - "spatial regions"
    }
  }
}
```

### Schema

```yaml
$defs:
  partitive_relation:
    properties:
      # ...
      criterion:
        type: object
        description: |
          The principle by which the comprehensive is divided
          into partitives. Optional; when present, distinguishes
          distinct decompositions of the same comprehensive.

          ISO 12620 coordinate-concept coherence: partitives
          within one relation share the comprehensive AND the
          criterion.

          Multilingual: keys are ISO 639 language codes.
        additionalProperties:
          type: string
        propertyNames:
          $ref: "#/$defs/iso639_three_char_code"
        # (matches the localized_text pattern)
```

Note: `criterion` is `type: object` (lang-keyed hash), not
`type: string`. It's concept-level metadata on a relation that
attaches at concept level (not localized), so multilingual form
is appropriate.

### Ontology

```turtle
gloss:criterion a owl:DatatypeProperty ;
  rdfs:domain gloss:PartitiveRelation ;
  rdfs:range rdf:langString ;
  rdfs:label "criterion"@en ;
  rdfs:comment "The subdivision criterion for a partitive relation. ISO 12620 coordinate-concept coherence."@en .
```

Note: `rdf:langString` range signals language-tagged literals.

### SHACL

```turtle
gloss:PartitiveRelationShape a sh:NodeShape ;
  # ...
  sh:property [
    sh:path gloss:criterion ;
    sh:datatype rdf:langString ;       # language-tagged literal
    sh:maxCount 1 ;                    # one criterion per relation
                                        # (multilingual via lang tags)
  ] .
```

Hmm, but a langString with multiple language tags is multiple
triples. The wire form is a hash; the RDF form is multiple
`gloss:criterion "..."@en, "..."@fr` triples. `sh:maxCount 1` would
reject the multilingual form.

Adjust:

```turtle
sh:property [
  sh:path gloss:criterion ;
  sh:datatype rdf:langString ;
  sh:qualifiedValueShape [
    sh:qualifiedMinCount 0 ;
    sh:qualifiedMaxCount 1 ;             # max 1 per language tag (implied by langString)
  ] ;
] .
```

Or simpler: just type-check, no count limit:

```turtle
sh:property [
  sh:path gloss:criterion ;
  sh:datatype rdf:langString ;
] .
```

### JSON-LD context

```jsonld
"criterion": { "@id": "gloss:criterion", "@container": "@language" },
```

`@container: @language` tells JSON-LD parsers that the wire form is
a language-keyed hash and should expand to multiple lang-tagged
literals.

### Examples

Update existing examples to include `criterion`:

```yaml
# Example 20 (closed, type-shared plurality):
partitive_relations:
  - comprehensive: { source: VIM, id: "112-02-09" }
    partitives:
      - ref: { source: VIM, id: "112-02-10" }
      - ref: { source: VIM, id: "112-03-26" }
    completeness: complete
    plurality: { is_shared: true }
    criterion:
      eng: "measurement result composition"
      fra: "composition du résultat de mesure"

# Example 21 (open, partial):
partitive_relations:
  - comprehensive: { source: VIM, id: "112-01-03" }
    partitives:
      - ref: { source: VIM, id: "112-01-04" }
      - ref: { source: VIM, id: "112-01-05" }
      - ref: { source: VIM, id: "112-01-22" }
    completeness: partial
    criterion:
      eng: "quantity system decomposition"
```

### Validators

New validator: `CheckPartitiveRelationCoherence` — for each
ManagedConcept with multiple PartitiveRelations, check:

1. **Error**: any two relations have identical `criterion` value
   (duplicate decomposition)
2. **Warning**: any relation has no `criterion` (cannot verify
   distinctness from siblings)
3. **Error**: a relation has fewer than 2 partitives (violates
   ISO "two or more")

Implemented as a Ruby validator class
`Glossarist::ConceptModel::Validators::CheckPartitiveRelationCoherence`.

## Verification

```bash
grep -A1 "criterion:" schemas/v3/examples/2*.yaml | head -20
make validate
bundle exec exe/check-partitive-relation-coherence   # new validator
```

## Migration

Existing data has no `criterion`. Migration leaves it absent.
Reviewers fill it in for relations that share a comprehensive with
other relations (to distinguish them).

For relations with a unique comprehensive, criterion is optional
(can be added later for clarity).

See `08-P1-migration-script.md`.

## Status: pending
