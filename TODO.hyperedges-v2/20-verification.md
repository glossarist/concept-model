# 20 — Verification

## Pre-conditions

Items 01-19 must be complete or explicitly deferred.

## Verification matrix

| Check | Command | Expected |
|-------|---------|----------|
| Turtle parse + cross-refs | `python scripts/validate-ontologies.py` | All OK |
| YAML examples valid | `python scripts/validate-examples.py` | OK: N files |
| Enum drift | `python scripts/check-enum-drift.py` | OK |
| JSON-LD context | `python scripts/check-jsonld-context.py` | OK: all properties covered |
| SHACL coverage | `python scripts/check-shacl-coverage.py` | OK: all classes shaped |
| LUTAML references | `python scripts/check-lutaml-references.py` | OK: all refs resolve |
| Negative examples rejected | `python scripts/validate-negative-examples.py` | OK: all negative examples fail |
| Script unit tests | `pytest scripts/tests/` | All pass |
| Makefile target | `make validate` | All checks pass |

## CI workflow

The `.github/workflows/validate-schemas.yml` runs:
- validate-examples
- check-enum-drift
- check-jsonld-context
- check-shacl-coverage
- check-lutaml-references
- validate-negative-examples
- script unit tests

## Sign-off

If all green, the architectural cleanup is complete. Open PR.

## Status: pending
