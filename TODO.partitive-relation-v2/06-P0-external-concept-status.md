# 06 — P0: ExternalConcept via `status: external`

## Problem

The current `ConceptRef` requires `source + id`. There's no way to
say "this concept exists in the world but we don't define it
ourselves — we just reference it, and it may resolve later."

ISO 704 calls these **parenthetic terms** (because they appear in
parentheses in text) — but "parenthetic" describes the typographic
convention, not the semantic role. The semantic role is: a concept
we reference but don't define; it lives externally and may be
resolved when another dataset is loaded.

## Design decision: ExternalConcept is a ManagedConcept with status: external

Not a separate class. Existing concept tooling works unchanged.

### Why a status value, not a new class

- **Existing infrastructure**: concept lookups, indexing,
  cross-references, file loading — all work without modification
- **Accumulation**: an ExternalConcept can gain partial data over
  time (a candidate source, a domain hint) without changing type
- **Resolution is a state transition** (status: external →
  status: valid), not a type migration
- **One concept model**: one set of validators, one UI path,
  one spec surface

### Cost: stricter conditional required-ness

ManagedConcept fields that are normally required (definition,
sources) become optional when status: external. Express via
`oneOf`:

```yaml
managed_concept:
  oneOf:
    - title: DefinedConcept
      required: [id, status, data]
      properties:
        status: { enum: [draft, submitted, not_valid, invalid, valid, superseded, retired] }
    - title: ExternalConcept
      required: [id, status, data]
      properties:
        status: { const: external }
```

The `data.designations` field is required for both (every concept
needs at least one designation — even external concepts have a name).

`data.definition`, `sources`, `dates` are all optional for
ExternalConcept.

## Scope

- `models/concepts/ConceptStatus.lutaml` — add `external` value
- `schemas/v3/concept.yaml` — add `external` to `concept_status` enum,
  add `oneOf` for required-ness
- `ontologies/taxonomies/concept-status.ttl` — add `external` concept
- `models/concepts/ConceptRef.lutaml` — make `source` and `id`
  optional (already are in schema), document text-only form

## Concrete changes

### LUTAML model

```ruby
# models/concepts/ConceptStatus.lutaml (updated)
enum ConceptStatus {
  definition { The normative status of the managed term. }
  draft { definition { Under development; not yet valid. } }
  submitted { definition { Submitted for review. } }
  not_valid { definition { Reviewed and not valid. } }
  invalid { definition { Invalid. } }
  valid { definition { Valid and in force. } }
  superseded { definition { Not valid; superseded by a new valid term. } }
  retired { definition { Formerly valid; no longer valid. } }
  external {
    definition {
      A concept referenced from this dataset but defined elsewhere.
      The concept exists in the world (we know its designation);
      we don't define it ourselves.

      Resolves to another dataset's concept when one is loaded
      that defines it (see RelatedConceptType#provided_by).

      ISO 704 calls these "parenthetic terms" — concepts taken as
      primitives, assumed generally understood. "External" describes
      the semantic role (definition lives outside our dataset);
      "parenthetic" describes the typographic convention only.

      ManagedConcept fields that are normally required (definition,
      sources) become optional for status:external concepts. At
      minimum, the concept must have one designation (the name by
      which it is referenced).
    }
  }
}
```

### Schema

```yaml
# schemas/v3/concept.yaml
$defs:
  concept_status:
    type: string
    description: The normative status of the managed term.
    enum:
      # ... existing values ...
      - external              # NEW

# Top-level: tighten required-ness based on status
properties:
  id: { type: string }
  status: { $ref: "#/$defs/concept_status" }
  data:
    type: object
    properties:
      identifier: { ... }
      designations: { ... }       # required for all (every concept has a name)
      definition: { ... }         # required for non-external; optional for external
      # ...

required:
  - id
  - status
  - data

allOf:
  - if:
      properties:
        status: { enum: [draft, submitted, not_valid, invalid, valid, superseded, retired] }
    then:
      required: [id, status, data]
      properties:
        data:
          required: [identifier, designations, definition]
  - if:
      properties:
        status: { const: external }
    then:
      required: [id, status, data]
      properties:
        data:
          required: [identifier, designations]
          # definition NOT required
```

### Taxonomy

```turtle
# ontologies/taxonomies/concept-status.ttl (updated)
<https://www.glossarist.org/ontologies/status/external> a skos:Concept ;
  skos:inScheme gloss:status ;
  skos:prefLabel "external"@en ;
  skos:definition "A concept referenced from this dataset but defined elsewhere. Resolves via provided_by when a defining dataset is loaded."@en .

gloss:status skos:hasTopConcept
    <https://www.glossarist.org/ontologies/status/draft> ,
    <https://www.glossarist.org/ontologies/status/valid> ,
    <https://www.glossarist.org/ontologies/status/retired> ,
    <https://www.glossarist.org/ontologies/status/external> .
```

### ConceptRef documentation

```ruby
# models/concepts/ConceptRef documentation (no change to structure,
# but document the text-only form)
class ConceptRef {
  definition {
    A reference to a concept by source + id, or a text-only
    placeholder for an external concept.

    Three forms:
      1. (source, id, text) — fully resolved, with optional
         display text
      2. (source, id) — resolved, no display override
      3. (text) — text-only; resolves to an ExternalConcept in
         the dataset's concepts/ directory

    Form 3 (text-only) is for inline convenience in authored
    YAML. On load, the deserializer creates or looks up an
    ExternalConcept with that text as its preferred designation
    and replaces the inline text-only ref with a (source, id)
    ref pointing at the ExternalConcept.
  }
  +source: String [0..1] { ... }
  +id: String [0..1] { ... }
  +text: String [0..1] { ... }
}
```

### Schema for ConceptRef

```yaml
$defs:
  concept_ref:
    type: object
    description: |
      A concept reference. Three forms:
        1. (source, id, text) — fully resolved
        2. (source, id) — resolved
        3. (text) — text-only placeholder for an ExternalConcept
    properties:
      source: { type: string }
      id: { type: string }
      text: { type: string }
    anyOf:
      - required: [source, id]
      - required: [text]
    additionalProperties: false
```

## Verification

```bash
# ExternalConcept example validates
cat schemas/v3/examples/_external/01-external-concept.yaml
python scripts/validate-examples.py

# ConceptStatus enum includes external
grep -A1 "external" schemas/v3/concept.yaml | head -3

# Taxonomy updated
grep "external" ontologies/taxonomies/concept-status.ttl
```

## New example

```yaml
# schemas/v3/examples/_external/01-external-concept.yaml
# An ExternalConcept: a concept we reference but don't define.
id: ext-001
status: external
data:
  identifier: ext-001
  designations:
    - designation: "quantum field theory"
      type: expression
      normative_status: admitted
  domains:
    - concept_id: physics
      source: EXAMPLE
      ref_type: domain
# No definition, no sources — that's the point of status: external.
# This concept will gain a `provided_by` edge when another dataset
# that defines "quantum field theory" is loaded.
status: external
date_accepted: "2026-07-23T00:00:00+00:00"
```

## Migration

No existing data uses ExternalConcept. Migration is opt-in:
datasets with text-only ConceptRefs (which are rare) can choose
to convert them to ExternalConcepts.

See `08-P1-migration-script.md` for the optional migration helper.

## Downstream impact

- glossarist-ruby: `ManagedConcept#status` accepts `external`;
  deserialization conditionally requires fields based on status
- glossarist-js: same conditional required-ness logic
- concept-browser: UI indicates external concepts (badge: "external");
  shows `provided_by` link when present

See `17-downstream-consumer-guide.md`.

## Status: pending
