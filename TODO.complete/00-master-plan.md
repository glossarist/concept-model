# TODO.complete — PartitiveHyperedge completion plan

## Why this exists

The contributor's `glossarist-ruby/TODO.hyperedges/45-summary.md` claims
"all 45 items complete." Cross-checking against the actual concept-model
state on 2026-07-22 found **6 phantom or partial completions** and
**3 regressions** introduced by the fixes themselves. This plan closes
those gaps and addresses items missed by both the contributor and the
prior maintainer audits.

## Verification methodology

Every claim of "✅ Done" in this plan is backed by:
1. A concrete file change (path + diff description).
2. A verification step (script run, SPARQL query, or grep assertion).

No "Status: ✅ Done" without an executable check.

## Priority definitions

- **P0** — broken on master right now (broken links, wrong URIs,
  incorrect version claims). Blocks merge of any size.
- **P1** — semantic gap or CI hole. Should land before the next
  consumer release.
- **P2** — polish, drift prevention, architectural cleanup.

## Scope

This plan covers the **concept-model repo** only. Cross-repo items
(ruby/js/browser) are tracked at the bottom as a checklist for the
contributor to execute in those repos — they cannot be implemented
from here.

## Execution order

```
Phase 1 (P0, mechanical fixes)  : 01 → 02 → 03
Phase 2 (P1, CI foundation)     : 04 → 05 → 06 → 07 → 08 → 09
Phase 3 (P1, semantic gaps)     : 10 → 11 → 12 → 13
Phase 4 (P2, polish)            : 14 → 15
Phase 5 (verification)          : 16 — run all scripts, confirm green
Phase 6 (cross-repo)            : tracked in 17, executed elsewhere
```

## Files

| # | Priority | Title |
|---|----------|-------|
| 01 | P0 | Fix SHACL `sh:valuesFrom` URI typos |
| 02 | P0 | Publish design doc (move out of gitignored TODO.hyperedge/) |
| 03 | P0 | Fix README version claim |
| 04 | P1 | Add SHACL `gloss:hyperedgeContent` property shape |
| 05 | P1 | Update JSON-LD context with new hyperedge terms |
| 06 | P1 | Improve `validate-examples.py` (schema-per-file, counts, --report-all) |
| 07 | P1 | Add `current` to concept_status enum (pre-existing 17/18 breakage) |
| 08 | P1 | Rewrite `check-enum-drift.py` (auto-discover + SHACL + LUTAML) |
| 09 | P1 | Wire validation scripts into CI |
| 10 | P1 | Document binary `has_part` vs `PartitiveHyperedge` overlap |
| 11 | P2 | Clean up `validate-ontologies.py` no-op block |
| 12 | P2 | Align `content` model type with schema |
| 13 | P1 | Move extraction-trigger doc out of gitignored dir |
| 14 | P1 | Cross-repo integration script (`scripts/integration.sh`) |
| 15 | P2 | Pre-existing SHACL URI mismatch (`conceptstatus` → `status`) |
| 16 | — | Verification: all scripts pass |
| 17 | — | Cross-repo items (glossarist-ruby, glossarist-js, concept-browser) |

## Architectural invariants enforced

- **I1 (MECE)**: every fact has exactly one canonical location; cross-references are documented, not duplicated silently.
- **I2 (OCP)**: adding a new enum or hyperedge type does not require modifying a hard-coded registry — discovery is data-driven.
- **I3 (DRY)**: a value declared in 5 places is checked against all 5 by a single CI script, not maintained by hand.
- **I4 (model-driven)**: the LUTAML model is the source of truth; the schema, SHACL, and JSON-LD context are derived representations, and drift among them is detectable.

## Code-quality rules honored

- No `send` to private methods.
- No `instance_variable_set` / `instance_variable_get`.
- No `respond_to?` for type checks.
- No `require_relative` for internal library code (Ruby autoload only).
- No doubles in specs (real model instances).
- No hand-rolled serialization (lutaml-model only).
- No hand-rolled `to_h` / `from_h` / `to_json` / `from_json`.
- No AI attribution in commits.
