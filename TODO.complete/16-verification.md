# 16 — Verification: all scripts pass

## Pre-conditions

Items 01-15 must be complete.

## Verification matrix

| Check | Command | Expected |
|-------|---------|----------|
| Turtle parse | `python scripts/validate-ontologies.py` | All `OK` |
| YAML examples valid | `python scripts/validate-examples.py` | `OK: N example files passed` |
| Enum drift | `python scripts/check-enum-drift.py` | `OK: ...` |
| SHACL URI cross-ref | (covered by `check-enum-drift.py`) | 0 broken URIs |
| LUTAML ↔ schema | (covered by `check-enum-drift.py`) | 0 drift |
| Doc references valid | `grep -r "TODO.hyperedge" README.adoc CHANGELOG.md` | no matches |
| Design doc published | `test -f docs/design/partitive-hyperedge.md` | 0 exit |
| README version accurate | `grep "v3\.1 introduces" README.adoc` | no matches |
| CI workflow added | `test -f .github/workflows/validate-schemas.yml` | 0 exit |
| JSON-LD context terms | `grep hyperedgeContent ontologies/glossarist.context.jsonld` | 1 match |
| SHACL hyperedgeContent shape | `grep -A2 hyperedgeContent ontologies/shapes/glossarist.shacl.ttl` | match |

## Sign-off

If all green, mark `TODO.complete/00-master-plan.md` "complete" and
open the PR.

## Status: pending
