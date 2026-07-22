# 17 — P2: Pre-commit hook config

## Problem

Today validation only runs in CI. Contributors may push broken
state and only discover it on PR review. Pre-commit hooks catch
issues locally before push.

## Fix

Add `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: validate-ontologies
        name: Validate ontology Turtle files
        entry: python scripts/validate-ontologies.py
        language: system
        pass_filenames: false
        files: ^ontologies/.*\.ttl$

      - id: validate-examples
        name: Validate YAML examples against JSON Schema
        entry: python scripts/validate-examples.py
        language: system
        pass_filenames: false
        files: ^schemas/v3/examples/.*\.yaml$

      - id: check-enum-drift
        name: Check enum drift across schema/SHACL/taxonomy/model
        entry: python scripts/check-enum-drift.py
        language: system
        pass_filenames: false
        files: ^(schemas/|models/|ontologies/)

      - id: check-jsonld-context
        name: Check JSON-LD context completeness
        entry: python scripts/check-jsonld-context.py
        language: system
        pass_filenames: false
        files: ^ontologies/

      - id: check-shacl-coverage
        name: Check SHACL shape coverage
        entry: python scripts/check-shacl-coverage.py
        language: system
        pass_filenames: false
        files: ^ontologies/

      - id: check-lutaml-references
        name: Check LUTAML class references resolve
        entry: python scripts/check-lutaml-references.py
        language: system
        pass_filenames: false
        files: ^models/.*\.lutaml$

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.39.0
    hooks:
      - id: markdownlint-cli

  - repo: https://github.com/codespell-project/codespell
    rev: v2.3.0
    hooks:
      - id: codespell
```

## Install

```bash
pip install pre-commit
pre-commit install
```

## Verification

```bash
pre-commit run --all-files
```

## Out of scope for this PR

Land after items 05, 06, 07 land (so the hooks have something to
call).

## Status: pending (P2)
