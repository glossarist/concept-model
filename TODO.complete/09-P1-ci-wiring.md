# 09 — P1: Wire validation scripts into CI

## Problem

`scripts/validate-examples.py` and `scripts/check-enum-drift.py` exist
but no `.github/workflows/*.yml` runs them. The contributor's
`TODO.hyperedges/35-P2-concept-model-validate-examples.md` explicitly
specified "Wire into CI" as part of the work. Not done.

Until wired, the scripts are documentation. Drift and example
breakage land in master silently.

## Fix

Create `.github/workflows/validate-schemas.yml`:

```yaml
name: validate-schemas

on:
  push:
    branches: [ main ]
    paths:
      - 'schemas/**'
      - 'models/**'
      - 'ontologies/**'
      - 'scripts/validate-examples.py'
      - 'scripts/check-enum-drift.py'
      - '.github/workflows/validate-schemas.yml'
  pull_request:
    paths:
      - 'schemas/**'
      - 'models/**'
      - 'ontologies/**'
      - 'scripts/validate-examples.py'
      - 'scripts/check-enum-drift.py'
      - '.github/workflows/validate-schemas.yml'

jobs:
  validate-examples:
    name: Validate YAML examples against JSON Schema
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install jsonschema pyyaml
      - run: python scripts/validate-examples.py

  check-enum-drift:
    name: Check enum drift across schema/SHACL/taxonomy/model
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install rdflib pyyaml
      - run: python scripts/check-enum-drift.py
```

Also update `.github/workflows/validate-ontologies.yml` to include
the new script paths in its trigger.

## Verification

- Push the branch; both jobs run and pass on PR.
- Trigger paths cover the right files (any schema/model/ontology
  change re-runs validation).

## Status: pending
