# 10 — P1: CONTRIBUTING.md

## Problem

No `CONTRIBUTING.md` exists. New contributors don't know:

- What files to touch when adding a new enum / class / property
- What scripts to run before pushing
- The architectural layering (model → schema → SHACL → context)
- The MECE responsibilities between layers

## Fix

Create `CONTRIBUTING.md` at repo root:

```markdown
# Contributing to glossarist concept-model

## Architectural layering

The concept-model is **model-driven**: the LUTAML model is the
source of truth. Everything else is derived.

```
models/*.lutaml  ── source of truth (classes, enums, attributes)
       │
       ├─→ schemas/v3/*.yaml        (JSON Schema, derived)
       ├─→ ontologies/glossarist.ttl (OWL ontology, derived)
       ├─→ ontologies/shapes/*.ttl   (SHACL shapes, derived)
       ├─→ ontologies/glossarist.context.jsonld (JSON-LD, derived)
       └─→ ontologies/taxonomies/*.ttl (SKOS schemes, derived)
```

Today these are hand-maintained in sync. The `scripts/check-*.py`
suite catches drift; CI runs the suite on every PR.

## Adding a new enum

1. Add the enum to a `.lutaml` file under `models/concepts/`.
2. Add the enum to `schemas/v3/concept.yaml` `$defs`.
3. Add a SKOS taxonomy file under `ontologies/taxonomies/`.
4. Reference the new taxonomy from the relevant SHACL shape
   (`sh:valuesFrom <...>`).
5. Add JSON-LD context entries for any new properties.

The CI drift checker will fail until all four sites agree.

## Adding a new class

1. Define the class in a `.lutaml` file under `models/`.
2. Add the class to `ontologies/glossarist.ttl` as `owl:Class`.
3. Add a SHACL `NodeShape` targeting the class.
4. Add the class to `ontologies/glossarist.context.jsonld`.
5. (Optional) Add example YAMLs under `schemas/v3/examples/`.

The CI coverage checker will fail until every class has a shape
and a context entry.

## Before pushing

```bash
make validate    # runs all scripts/*.py
```

Or individually:

```bash
python scripts/validate-examples.py
python scripts/validate-ontologies.py
python scripts/check-enum-drift.py
python scripts/check-jsonld-context.py
python scripts/check-shacl-coverage.py
python scripts/check-lutaml-references.py
```

## Commit message conventions

- `feat(model): ...` for new model features
- `fix(schema): ...` for schema bug fixes
- `chore(ci): ...` for CI changes
- `docs: ...` for documentation

No AI attribution. See `~/.claude/CLAUDE.md` for the rule.

## Release process

See `RELEASE_PROCESS.md`. Summarized: every PR that touches
`ontologies/` or `schemas/` triggers the release-reminder bot.
The maintainer decides the semver bump after merge.
```

## Verification

```bash
test -f CONTRIBUTING.md
```

## Status: pending
