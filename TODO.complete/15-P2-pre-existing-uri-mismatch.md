# 15 — P2: Pre-existing SHACL URI mismatch (`conceptstatus` → `status`)

## Problem

While auditing item 01, I discovered the same URI-mismatch pattern in
existing (pre-hyperedge) SHACL:

```
SHACL references:  <.../conceptstatus>
Actual scheme:     gloss:status  (file: concept-status.ttl)
```

This is pre-existing, not introduced by the contributor. But fixing
it is the same one-line change as item 01, and leaving it sets a
broken precedent for future contributors.

## Fix

```diff
- sh:valuesFrom <https://www.glossarist.org/ontologies/conceptstatus> ;
+ sh:valuesFrom <https://www.glossarist.org/ontologies/status> ;
```

Apply in `ontologies/shapes/glossarist.shacl.ttl` wherever the old
URI appears.

## Verification

The rewritten `check-enum-drift.py` (item 08) will report any
remaining broken URIs. Run after fix:

```bash
python scripts/check-enum-drift.py
# Expected: 0 broken URI references
```

## Status: pending
