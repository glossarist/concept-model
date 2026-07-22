# Glossarist concept-model architecture

## Source-of-truth layering

```
models/*.lutaml  ──── source of truth (classes, enums, attributes)
       │
       ├──→ schemas/v3/*.yaml                       (JSON Schema, wire format)
       ├──→ ontologies/glossarist.ttl               (OWL ontology, RDF classes + properties)
       ├──→ ontologies/shapes/glossarist.shacl.ttl  (SHACL constraints)
       ├──→ ontologies/glossarist.context.jsonld    (JSON-LD term → IRI mapping)
       └──→ ontologies/taxonomies/*.ttl             (SKOS schemes for enums)
```

The LUTAML model is canonical. All other artifacts are derived and
must stay in sync. Seven pure-Ruby validators
(`lib/glossarist/concept_model/validators/`) enforce the sync,
invoked via `exe/` shims or `make validate`.

## MECE responsibilities per artifact

| Artifact | Owns | Does NOT own |
|----------|------|--------------|
| `models/*.lutaml` | Class shape, attributes, cardinality, definition prose | Wire format, RDF, validation rules |
| `schemas/v3/*.yaml` | Wire format for YAML/JSON consumers | RDF representation, validation timing |
| `ontologies/glossarist.ttl` | RDF classes, properties, domain/range | Wire format, SHACL constraints |
| `ontologies/shapes/*.ttl` | SHACL constraints (cardinality, datatype, sh:in) | Ontology classes |
| `ontologies/taxonomies/*.ttl` | SKOS schemes for enumerated values | Enum cardinality |
| `ontologies/glossarist.context.jsonld` | JSON-LD term → IRI mapping | Class shape, validation |
| `lib/glossarist/concept_model/validators/*.rb` | Drift detection across the above | Authoring |
| `exe/*` | CLI shims that load lib + invoke a validator | Validator logic |

## Data flow: authoring to consumption

```
Author writes YAML
   │
   ↓
glossarist-ruby parses  →  V3::ManagedConcept instances
   │
   ↓
glossarist-js parses   →  Concept instances
   │
   ↓
concept-browser builds →  hyperedges.json + edges.json
   │
   ↓
Reader browses
```

At each arrow, the model files in this repo define what's valid.

## Architectural invariants

- **I1 (MECE)**: every fact has one canonical location; cross-references documented, not duplicated silently.
- **I2 (OCP)**: adding a new type doesn't require editing switch statements — registry-driven discovery.
- **I3 (DRY)**: shared shapes factored; CI catches drift.
- **I4 (model-driven)**: LUTAML is SSOT; downstream artifacts derived.
- **I5 (closed-world schemas)**: `additionalProperties: false` everywhere except where backward compatibility requires otherwise (documented per `$def`).

## Concept relationships: three layers

Concept-to-concept relationships live at three levels, each MECE:

1. **Binary edges** (`related: [{type, ref, content}]` at concept
   level) — for one-to-one typed semantic links (deprecates, broader,
   equivalent, etc.). Wire field: top-level `related:` array. 52
   types in `RelatedConceptType`.

2. **Designation-level relationships** (`designations[].related`) —
   for relationships between specific designations of a concept
   (`abbreviated_form_for`, `short_form_for`). Same `RelatedConceptType`
   enum but only the designation-level subset applies.

3. **Partitive hyperedges** (`partitive_hyperedges: [{comprehensive,
   parts, enumeration, markers, content}]`) — for one-to-many
   partitive decompositions where membership is jointly significant
   or diagram notation applies.

The three coexist; an author chooses per relationship based on
cardinality and notation needs. See
`docs/design/partitive-hyperedge.md` for the design rationale.

## Adding a new model element

See `CONTRIBUTING.md`.
