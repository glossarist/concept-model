# 18 — Verification

## Pre-conditions

Items 01–14 must be complete. Items 15–16 are noted-only (P2,
future work). Item 17 is tracking-only (execute in other repos).

## Verification matrix

### In this repo (concept-model)

| Check | Command | Expected |
|-------|---------|----------|
| Turtle parse + cross-refs | `bundle exec exe/validate-ontologies` | OK |
| YAML examples valid | `bundle exec exe/validate-examples` | OK |
| Negative examples rejected | `bundle exec exe/validate-negative-examples` | OK |
| Enum drift | `bundle exec exe/check-enum-drift` | OK |
| JSON-LD context completeness | `bundle exec exe/check-jsonld-context` | OK |
| SHACL coverage | `bundle exec exe/check-shacl-coverage` | OK |
| LUTAML references resolve | `bundle exec exe/check-lutaml-references` | OK |
| PartitiveRelation coherence | `bundle exec exe/check-partitive-relation-coherence` | OK |
| ExternalConcept shape | `bundle exec exe/check-external-concept-shape` | OK |
| Binary has_part redundancy | `bundle exec exe/check-binary-has-part-redundancy` | OK (warnings allowed) |
| RSpec suite | `bundle exec rspec spec/` | All pass |
| Migration dry-run | `bundle exec exe/migrate-to-partitive-relation-v2 --dry-run schemas/v3/examples/` | Reports no changes (examples already v2) |

### Combined via Makefile

```bash
make validate
```

Runs all 10 validators + RSpec. Must pass clean.

### Doc reference integrity

```bash
# No v1 references in published docs
! grep -rE "PartitiveHyperedge|partitive_hyperedge|partitive_enumeration|PluralityMarker|plurality_marker|enumeration:\s+(closed|open)" \
    README.adoc CHANGELOG.md CONTRIBUTING.md ARCHITECTURE.md docs/

# Design doc renamed
test -f docs/design/partitive-relation.md
test ! -f docs/design/partitive-hyperedge.md
```

### CI workflow

`.github/workflows/validate-schemas.yml` runs all 10 validators +
RSpec. All must pass on PR.

## Downstream repo verification (tracking only)

| Repo | Check |
|------|-------|
| glossarist-ruby | `bundle exec rspec` — 0 failures |
| glossarist-js | `npm test` — 0 failures |
| concept-browser | `npm test` — 0 failures |
| vocab datasets | `ruby scripts/validate_datasets.rb --datasets vim-2007,vim-2010,vim-2012` |

These run in their respective CIs. Track via
`TODO.partitive-relation-v2/17-downstream-consumer-guide.md`.

## Sign-off

If all green:
1. Tag concept-model `v3.2.0` (semver minor: additive new feature,
   no removal in this release)
2. Notify downstream consumers per the rollout checklist
3. Open follow-up issues for items 15 (SequentialRelation) and 16
   (Definition types)

## Status: pending
