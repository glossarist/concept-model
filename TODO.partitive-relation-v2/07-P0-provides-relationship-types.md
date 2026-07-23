# 07 — P0: Add `provides` / `provided_by` to RelatedConceptType

## Problem

ExternalConcepts (status: external) need a way to record resolution:
when dataset B's concept X is found to be the substance for dataset
A's external concept ext-001, the link must be stored somewhere.

ISO 19135's `supersedes` / `superseded_by` was the prior proposal.
Wrong: `supersedes` implies replacement (the old thing is gone).
What we have is **fulfillment** — the external concept remains
(references still point at it), and a real concept comes along to
fill its substance.

The link is also directional in an important way: dataset B doesn't
know about A's external concepts. The link is established at the
**collection level** (whoever has both datasets loaded), and stored
on the ExternalConcept in dataset A.

## Decision: `provides` / `provided_by` as binary edges

Add two values to `RelatedConceptType`:

- `provides` — subject concept provides substance for the object
  external concept
- `provided_by` — subject external concept is provided by the
  object concept

Direction convention (subject → object) matches all other
relationship types.

## Why this verb

| Verb | Fit | Issue |
|------|-----|-------|
| `implements` | interface/impl pattern | Technical connotation; external concept isn't an "interface" |
| `defines` | declaration/definition pattern | Collides with `has_definition` / `definition_of` (ISO 19135) |
| `provides` | need/fulfillment pattern | **Clean, no collision, natural English** |
| `supersedes` | replacement | Wrong semantic — external concept remains |

## Scope

- `models/concepts/RelatedConceptType.lutaml` — add `provides` and
  `provided_by`
- `schemas/v3/concept.yaml` — add to `related_concept_type` enum
- `ontologies/taxonomies/relationship-type.ttl` — add SKOS concepts
- `ontologies/glossarist.ttl` — add `gloss:provides` /
  `gloss:providedBy` properties
- `ontologies/glossarist.context.jsonld` — add terms

## Concrete changes

### LUTAML model

```ruby
# models/concepts/RelatedConceptType.lutaml (updated)
enum RelatedConceptType {
  definition { ... }
  # ... existing 52 types ...

  // ── ExternalConcept resolution (Glossarist extension) ───────────
  provides {
    definition {
      The current concept provides the substance for an
      ExternalConcept. Established at the collection level: the
      collection manager (human or auto-resolution routine) who
      has both datasets loaded adds this edge when matching an
      external concept to its real definition.

      Direction: real concept (subject) → external concept (object).
      The inverse is `provided_by`.
    }
  }
  provided_by {
    definition {
      The current ExternalConcept is provided by the object
      concept — the object concept is its real definition.

      Direction: external concept (subject) → real concept (object).
      The inverse is `provides`.

      Convention: store the edge on the ExternalConcept (in its
      home dataset) rather than on the providing concept. The
      ExternalConcept is the source of truth for its own
      placeholders.
    }
  }
}
```

### Schema

```yaml
# schemas/v3/concept.yaml
$defs:
  related_concept_type:
    enum:
      # ... 52 existing values ...
      # ExternalConcept resolution
      - provides
      - provided_by
```

### Taxonomy

```turtle
# ontologies/taxonomies/relationship-type.ttl (updated)
<https://www.glossarist.org/ontologies/rel/provides> a skos:Concept ;
  skos:inScheme gloss:rel ;
  skos:prefLabel "provides"@en ;
  skos:definition "The current concept provides the substance for an external concept."@en ;
  rdfs:seeAlso <https://www.glossarist.org/ontologies/rel/provided_by> .

<https://www.glossarist.org/ontologies/rel/provided_by> a skos:Concept ;
  skos:inScheme gloss:rel ;
  skos:prefLabel "provided by"@en ;
  skos:definition "The current external concept is provided by another concept."@en ;
  rdfs:seeAlso <https://www.glossarist.org/ontologies/rel/provides> .

# Inverse pair
<https://www.glossarist.org/ontologies/rel/provides>
  owl:inverseOf <https://www.glossarist.org/ontologies/rel/provided_by> .
```

### Ontology

```turtle
# ontologies/glossarist.ttl (updated)
gloss:provides a owl:ObjectProperty ;
  rdfs:subPropertyOf gloss:hasRelatedConcept ;
  rdfs:label "provides"@en ;
  rdfs:comment "The subject concept provides substance for the object external concept."@en .

gloss:providedBy a owl:ObjectProperty ;
  rdfs:subPropertyOf gloss:hasRelatedConcept ;
  rdfs:label "provided by"@en ;
  rdfs:comment "The subject external concept is provided by the object concept."@en ;
  owl:inverseOf gloss:provides .
```

### JSON-LD context

```jsonld
"provides":    { "@id": "gloss:provides", "@type": "@id" },
"provided_by": { "@id": "gloss:providedBy", "@type": "@id" },
```

Note: JSON-LD term uses snake_case (`provided_by`) matching the
enum value; `@id` uses camelCase (`gloss:providedBy`) matching
ontology convention.

## Example: resolution flow

```yaml
# Dataset A: concepts/ext-001.yaml
id: ext-001
status: external
data:
  identifier: ext-001
  designations:
    - designation: "quantum field theory"
      type: expression
# (no related edges yet — unresolved)

# Dataset B: concepts/qft.yaml
id: qft
status: valid
data:
  identifier: qft
  designations:
    - designation: "quantum field theory"
      type: expression
      normative_status: preferred
  definition:
    - content: "A theoretical framework combining quantum mechanics and field theory..."

# Collection manager (after loading both datasets):
# 1. Auto-resolution matches ext-001.text → qft.designations[0].designation
# 2. Collection manager adds edge to ext-001:
#
# concepts/ext-001.yaml (updated):
id: ext-001
status: external
data:
  identifier: ext-001
  designations:
    - designation: "quantum field theory"
      type: expression
related:
  - type: provided_by
    ref: { source: urn:dataset-b, id: qft }
```

The edge lives on the ExternalConcept (in dataset A). Dataset B
is untouched. Future references to `ext-001` can transparently
use `qft`'s data via the `provided_by` link.

## Verification

```bash
# Enum updated
grep -E "provides|provided_by" schemas/v3/concept.yaml
# Taxonomy updated
grep "provides\|provided_by" ontologies/taxonomies/relationship-type.ttl
# Inverse relationship declared
grep "owl:inverseOf" ontologies/taxonomies/relationship-type.ttl

make validate
bundle exec exe/check-enum-drift
```

## Downstream impact

- glossarist-ruby: `RelatedConceptType` enum accepts new values.
  Auto-resolution routine (future work) writes `provided_by` edges.
- glossarist-js: parser/serializer accept new enum values.
- concept-browser: UI surfaces resolution links ("resolved by: qft").

See `17-downstream-consumer-guide.md`.

## Status: pending
