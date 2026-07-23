# 01 — P0: Rename PartitiveHyperedge → PartitiveRelation; parts → partitives

## Problem

The shipped name `PartitiveHyperedge` was a graph-theoretic framing.
ISO 704 / 1087-1 / 12620 call this a **partitive relation**. The
"hyperedge" name suggested a different semantic than what the
standards describe, confusing contributors and consumers.

The `parts` field name is also imprecise: the standard calls them
**partitive concepts** (subordinate concepts partitive). Each entry
is a member of the relation carrying a ConceptRef and (optionally)
certainty metadata, so the field holds `PartitiveMember` instances,
not raw ConceptRefs.

## Scope

- `models/concepts/PartitiveHyperedge.lutaml` → rename + restructure
- `models/concepts/ManagedConcept.lutaml` — rename role
- `schemas/v3/concept.yaml` — rename $def and property
- `schemas/v3/examples/20-*.yaml` through `23-*.yaml` — update keys
- `schemas/v3/examples/_negative/*.yaml` — update keys
- `ontologies/glossarist.ttl` — rename class and properties
- `ontologies/shapes/glossarist.shacl.ttl` — rename shape
- `ontologies/glossarist.context.jsonld` — rename terms
- `docs/design/partitive-hyperedge.md` → rename to `partitive-relation.md`
- `README.adoc`, `CHANGELOG.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md` — update references

## Concrete changes

### LUTAML model

```ruby
# models/concepts/PartitiveRelation.lutaml (renamed from PartitiveHyperedge.lutaml)
class PartitiveRelation {
  definition {
    ISO 704 / ISO 1087-1 / ISO 12620 partitive relation.

    Connects a comprehensive concept (superordinate concept
    partitive) to two or more partitive concepts (subordinate
    concepts partitive) which fitted together constitute the
    comprehensive.

    Shown as a rake or bracket in source diagrams. All partitives
    within one relation are coordinate concepts: they share the
    comprehensive AND share the criterion of subdivision.

    Glossarist extensions beyond ISO notation:
      - Per-partitive certainty (MemberCertainty)
      - plurality.shared_type (the type the partitives share)
      - criterion as a structured field (not just diagrammatic)
  }
  +comprehensive: <<StandardDocument>> ReferenceToTermbase [1] {
    definition { The superordinate concept partitive — the whole. }
  }
  +partitives: PartitiveMember [2..*] {
    definition {
      The subordinate concepts partitive — the parts. Each member
      carries a ConceptRef and optional certainty metadata.

      ISO 704 requires "two or more." A single partitive should be
      expressed as a binary has_part edge instead.
    }
  }
  +completeness: Completeness [0..1] { ... }
  +plurality: TypeSharedPlurality [0..1] { ... }
  +criterion: <<BasicDocument>> LocalizedString [0..1] { ... }
}
```

### New LUTAML: PartitiveMember

```ruby
# models/concepts/PartitiveMember.lutaml
class PartitiveMember {
  definition {
    One member of a PartitiveRelation — a partitive concept plus
    optional certainty metadata.

    A PartitiveMember with no certainty field is implicitly
    confirmed.
  }
  +ref: <<StandardDocument>> ReferenceToTermbase [1] {
    definition { The subordinate concept partitive — the part. }
  }
  +certainty: MemberCertainty [0..1] {
    definition {
      Glossarist extension. Per-member certainty beyond what ISO
      notation expresses. Defaults to confirmed when omitted.
    }
  }
}
```

### ManagedConcept role rename

```ruby
# models/concepts/ManagedConcept.lutaml
class ManagedConcept {
  # ...
  +partitive_relations: PartitiveRelation [0..*] { ... }
  # was: +partitive_hyperedges: PartitiveHyperedge [0..*]
}
```

### Schema rename

```yaml
# schemas/v3/concept.yaml
properties:
  # ...
  partitive_relations:                       # was: partitive_hyperedges
    type: array
    items:
      $ref: "#/$defs/partitive_relation"     # was: partitive_hyperedge

$defs:
  # ...
  partitive_relation:                        # was: partitive_hyperedge
    type: object
    # ...
    properties:
      comprehensive: { $ref: "#/$defs/concept_ref" }
      partitives:                            # was: parts
        type: array
        minItems: 2                          # was: 1; ISO requires "two or more"
        items:
          $ref: "#/$defs/partitive_member"
      # ...
```

### Examples

Every example file with `partitive_hyperedges:` becomes
`partitive_relations:`. Every `parts:` becomes `partitives:`. Each
entry in `parts:` (previously a bare ConceptRef) becomes a
`PartitiveMember`:

```yaml
# Before:
partitive_hyperedges:
  - comprehensive: { source, id }
    parts:
      - { source, id }
      - { source, id }

# After:
partitive_relations:
  - comprehensive: { source, id }
    partitives:
      - ref: { source, id }
      - ref: { source, id }
```

### Ontology

```turtle
# ontologies/glossarist.ttl
gloss:PartitiveRelation a owl:Class ;            # was: gloss:PartitiveHyperedge
  rdfs:label "Partitive Relation"@en ;
  # ...
.

gloss:hasPartitiveRelation a owl:ObjectProperty ; # was: gloss:hasPartitiveHyperedge
  rdfs:domain gloss:Concept ;
  rdfs:range gloss:PartitiveRelation ;
  # ...
.

# gloss:comprehensive — unchanged
# gloss:hasPart — DEPRECATED (use gloss:hasPartitive); kept for one release
gloss:hasPartitive a owl:ObjectProperty ;
  rdfs:domain gloss:PartitiveRelation ;
  rdfs:range gloss:PartitiveMember ;
  rdfs:label "has partitive"@en ;
  rdfs:comment "A partitive member of a PartitiveRelation."@en .
.

gloss:PartitiveMember a owl:Class ;
  rdfs:label "Partitive Member"@en ;
  rdfs:comment "One member of a PartitiveRelation — a ConceptRef plus certainty metadata."@en .
.
```

### SHACL

```turtle
# ontologies/shapes/glossarist.shacl.ttl
gloss:PartitiveRelationShape a sh:NodeShape ;    # was: PartitiveHyperedgeShape
  sh:targetClass gloss:PartitiveRelation ;
  sh:property [
    sh:path gloss:comprehensive ;
    sh:class gloss:ConceptRef ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:hasPartitive ;                # was: gloss:hasPart
    sh:class gloss:PartitiveMember ;
    sh:minCount 2 ;                             # ISO: "two or more"
  ] ;
  # ...
.

gloss:PartitiveMemberShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveMember ;
  sh:property [
    sh:path gloss:ref ;
    sh:class gloss:ConceptRef ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:certainty ;
    sh:class skos:Concept ;
    sh:valuesFrom <https://www.glossarist.org/ontologies/memberCertainty> ;
    sh:maxCount 1 ;
  ] .
.
```

### JSON-LD context

```jsonld
"PartitiveRelation":  "gloss:PartitiveRelation",       // was: PartitiveHyperedge
"PartitiveMember":    "gloss:PartitiveMember",          // new
"hasPartitiveRelation": { "@id": "gloss:hasPartitiveRelation", "@type": "@id" },  // was: hasPartitiveHyperedge
"hasPartitive":       { "@id": "gloss:hasPartitive", "@type": "@id" },            // was: hasPart
// "comprehensive" — unchanged
```

### Docs rename

- `docs/design/partitive-hyperedge.md` → `docs/design/partitive-relation.md`
- All `partitive_hyperedge` / `PartitiveHyperedge` references updated

## Verification

```bash
# No remaining references to old name
! grep -r "PartitiveHyperedge\|partitive_hyperedge\|partitive_hyperedges" \
    models/ schemas/ ontologies/ docs/ README.adoc CHANGELOG.md \
    CONTRIBUTING.md ARCHITECTURE.md

# All examples use new shape
grep -L "partitive_relations:" schemas/v3/examples/2*.yaml | grep -v _negative
# (returns nothing)

make validate
```

## Migration impact

Existing datasets using `partitive_hyperedges:` need migration.
See `08-P1-migration-script.md`.

## Status: pending
