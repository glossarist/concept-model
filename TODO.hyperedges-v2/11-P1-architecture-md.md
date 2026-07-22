# 11 — P1: ARCHITECTURE.md

## Problem

No `ARCHITECTURE.md`. The layering is implicit. New contributors
take weeks to figure out which file owns what.

## Fix

Create `ARCHITECTURE.md` at repo root with:

1. The layering diagram (same as CONTRIBUTING.md).
2. A table of MECE responsibilities per file/dir.
3. The 5 architectural invariants (from `TODO.complete/00`).
4. The data flow from authoring to consumption.

## Concrete content

```markdown
# Glossarist concept-model architecture

## Source-of-truth layering

[diagram from CONTRIBUTING.md]

## MECE responsibilities

| Artifact | Owns | Does NOT own |
|----------|------|--------------|
| `models/*.lutaml` | Class shape, attributes, cardinality, definition prose | Wire format, RDF, validation rules |
| `schemas/v3/*.yaml` | Wire format for YAML/JSON consumers | RDF representation, validation timing |
| `ontologies/glossarist.ttl` | RDF classes, properties, domain/range | Wire format, SHACL constraints |
| `ontologies/shapes/*.ttl` | SHACL constraints (cardinality, datatype, sh:in) | Ontology classes |
| `ontologies/taxonomies/*.ttl` | SKOS schemes for enumerated values | Enum cardinality |
| `ontologies/glossarist.context.jsonld` | JSON-LD term → IRI mapping | Class shape, validation |

## Data flow

```
Author writes YAML
   ↓
glossarist-ruby parses → V3::ManagedConcept instances
   ↓
glossarist-js parses → Concept instances
   ↓
concept-browser builds → hyperedges.json + edges.json
   ↓
Reader browses
```

At each arrow, the model files in this repo define what's valid.

## Architectural invariants

- **I1 (MECE)**: every fact has one canonical location.
- **I2 (OCP)**: adding a new type doesn't require editing switch statements.
- **I3 (DRY)**: shared shapes factored; CI catches drift.
- **I4 (model-driven)**: LUTAML is SSOT.
- **I5 (closed-world schemas)**: `additionalProperties: false` everywhere.

## Adding a new model element

See CONTRIBUTING.md.
```

## Verification

```bash
test -f ARCHITECTURE.md
```

## Status: pending
