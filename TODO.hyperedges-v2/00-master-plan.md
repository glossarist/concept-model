# TODO.hyperedges-v2 — Deeper architectural cleanup

## Why this exists

`TODO.complete/` addressed the PartitiveHyperedge-specific gaps the
contributor left behind. This second pass goes broader: structural
issues across the whole concept-model that surfaced while auditing
the hyperedge work.

Findings come from cross-checking the ontology, SHACL, JSON-LD
context, JSON Schema, LUTAML models, and the Python scripts against
each other. The new `check-enum-drift.py` from `TODO.complete/`
proved the pattern — extend it to cover the rest of the model
surface.

## Verification methodology

Every "✅ Done" backed by:
1. A concrete file change.
2. An executable check (script run, SPARQL, or grep assertion).

## Priority definitions

- **P0** — wrong on master right now (missing context terms, missing
  SHACL shapes, schemas that accept arbitrary garbage).
- **P1** — coverage hole or contributor-onboarding gap. Should land
  before the next consumer release.
- **P2** — architectural cleanup that pays off over the next 6-12
  months as the model grows.

## Scope

concept-model repo only. Cross-repo items tracked at the bottom.

## Findings summary

| Finding | Count | Where |
|---------|-------|-------|
| Ontology properties missing from JSON-LD context | 4 | `relatedConceptBroader`, `relatedConceptNarrower`, `source`, `tag` |
| Ontology classes with no SHACL shape | 5 | `PartitiveEnumeration`, `PluralityMarker`, `FigureImage`, `NonVerbalEntity`, `SharedNonVerbalEntity` |
| `$defs` without `additionalProperties: false` | 16 of 17 | every def except `partitive_hyperedge` |
| `$defs` with shared `source + id` shape not factored | 3 | `concept_ref`, `reference`, `citation_ref` |
| Python scripts with no test coverage | 3 | `validate-examples`, `check-enum-drift`, `validate-ontologies` |
| Onboarding docs missing | 2 | `CONTRIBUTING.md`, `ARCHITECTURE.md` |
| Makefile target for validation | 0 | none |

## Execution order

```
Phase 1 (P0, fill the holes)     : 01 → 02 → 03 → 04
Phase 2 (P1, CI coverage)        : 05 → 06 → 07 → 08
Phase 3 (P1, contributor UX)     : 09 → 10 → 11 → 12
Phase 4 (P1, model docs)         : 13 → 14
Phase 5 (P2, structural)         : 15 → 16 → 17 → 18 → 19
Phase 6 (verification)           : 20
```

## Files

| # | Priority | Title |
|---|----------|-------|
| 01 | P0 | Add missing JSON-LD context terms (4 properties) |
| 02 | P0 | Add SHACL shapes for 5 unshaped classes |
| 03 | P0 | Tighten `$defs` with `additionalProperties: false` |
| 04 | P0 | Factor shared `source+id` shape into a reusable $def |
| 05 | P1 | `scripts/check-jsonld-context.py` (cross-check vs ontology) |
| 06 | P1 | `scripts/check-shacl-coverage.py` (every class has a shape) |
| 07 | P1 | `scripts/check-lutaml-references.py` (catch broken model refs) |
| 08 | P1 | pytest suite for the three validation scripts |
| 09 | P1 | Curated negative test cases |
| 10 | P1 | `CONTRIBUTING.md` with layering + checklist |
| 11 | P1 | `ARCHITECTURE.md` diagram and prose |
| 12 | P1 | `Makefile` validate target |
| 13 | P1 | `Concept#domain` vs `Concept#subject` doc clarification |
| 14 | P1 | Designation-level vs concept-level `related` MECE doc |
| 15 | P2 | Generate JSON-LD context from ontology (SSOT) |
| 16 | P2 | Modularize `glossarist.ttl` by domain |
| 17 | P2 | Pre-commit hook config |
| 18 | P2 | `argparse` + type hints for Python scripts |
| 19 | P2 | Round-trip test framework |
| 20 | — | Verification |

## Architectural invariants this plan enforces

- **I1 (MECE)**: every fact has one canonical location; `Concept#domain` vs `Concept#subject` documented; concept-level vs designation-level `related` distinguished.
- **I2 (OCP)**: adding a new class/enumeration/property triggers a CI check that tells you which other files need updating.
- **I3 (DRY)**: shared shapes factored out; JSON-LD context generator removes hand-maintenance.
- **I4 (model-driven)**: ontology is the SSOT; SHACL, context, schema are derived.
- **I5 (closed-world schemas)**: `additionalProperties: false` everywhere — schemas reject what they don't define.

## Code-quality rules honored

Same as `TODO.complete/00-master-plan.md`. Plus for Python:
- No `_Class__method` name-mangling bypasses.
- No `object.__dict__` access.
- No `hasattr()` for type checks (use `isinstance`).
- Module-level constants UPPER_SNAKE; functions snake_case.
