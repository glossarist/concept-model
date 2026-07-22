# 19 — P2: Round-trip test framework

## Problem

Today we validate that examples parse. We don't validate that
parsed examples can be re-emitted to the same YAML. Drift between
parser and serializer (in any consumer repo) silently corrupts
data.

## Fix

Add a round-trip test framework:

```python
# scripts/tests/test_round_trip.py
"""For each example YAML, verify:
  1. parse(YAML) → DOC
  2. emit(DOC) → YAML'
  3. parse(YAML') → DOC'
  4. assert DOC == DOC'

Uses jsonschema's arbitrary dict representation, so this only
catches serializer/parser asymmetry, not model-level round-trip
(glossarist-ruby / glossarist-js cover that).
"""
```

The model-level round-trip (parse → model object → emit) requires
glossarist-ruby / glossarist-js / concept-browser specs. Those
live in their respective repos; tracked in
`TODO.complete/17-cross-repo-items.md`.

## Scope of this script

Just YAML-level round-trip with PyYAML:
- `yaml.safe_load(x)` → `yaml.safe_dump(...)` → `yaml.safe_load(...)`
- Compare the two loaded structures.

Catches:
- Anchor/alias issues
- Quoting style changes
- Key ordering (sort_keys consistency)
- Multi-doc stream preservation

## Verification

```bash
pytest scripts/tests/test_round_trip.py -v
```

## Out of scope for this PR

Land alongside items 08 and 09.

## Status: pending (P2)
