# 21 — Summary

## Item count

| Priority | Count | Scope |
|----------|-------|-------|
| P0 | 4 | fill holes in JSON-LD context, SHACL shapes, additionalProperties, DRY factor-out |
| P1 | 10 | CI scripts (3), test infra (2), contributor UX (3), model docs (2) |
| P2 | 5 | generator, modularization, hooks, argparse, round-trip |
| Verification | 1 | run everything |

## What this plan addresses that `TODO.complete/` didn't

`TODO.complete/` was PartitiveHyperedge-specific. This plan
addresses project-wide architectural debt:

- **Closed-world schemas** (item 03) — the schema accepts
  arbitrary garbage today.
- **Coverage checkers** (items 05, 06, 07) — drift between
  ontology ↔ context ↔ SHACL ↔ LUTAML was invisible.
- **Test infrastructure** (items 08, 09) — the Python scripts
  had no tests.
- **Contributor onboarding** (items 10, 11, 12) — no
  CONTRIBUTING.md, no ARCHITECTURE.md, no Makefile target.
- **Model documentation gaps** (items 13, 14) — Concept#domain
  vs #subject, related-level MECE.

## Architectural invariants enforced

- **I1 (MECE)**: documented between Concept#domain/#subject,
  concept-level/designation-level `related`, and the JSON-LD
  context vs ontology.
- **I2 (OCP)**: adding a new class/enum triggers CI to tell you
  what else needs updating.
- **I3 (DRY)**: shared `source+id` shape factored (item 04).
- **I4 (model-driven)**: LUTAML is SSOT; downstream artifacts
  checked against it.
- **I5 (closed-world)**: `additionalProperties: false` everywhere.

## Code-quality rules honored

Same as prior plans. Plus:
- Python: no `_Class__method` bypasses.
- Python: no `object.__dict__` access.
- Python: no `hasattr()` for type checks.
- Python: module constants UPPER_SNAKE.

## Out of scope (tracked elsewhere)

- Cross-repo work: `TODO.complete/17-cross-repo-items.md`.
- Performance benchmarks: separate workstream.
- Vocab dataset migration: separate workstream.

## What's next

Land P0 items in this PR. P1 items either in this PR or a tight
follow-up. P2 items as separate dedicated PRs (each is large
enough to warrant isolation).
