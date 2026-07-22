# 14 — P1: Designation-level vs concept-level `related` MECE

## Problem

The `related` field appears at multiple levels:

- `concept.yaml` top-level `related` (concept-level)
- Designation-level `related` (inside `designations[].related`)

The V3 invariant (per cross-repo plan I1) says concept-level
only. But the schema still allows designation-level `related`
for ISO 10241-1 designation-level relationships
(`abbreviated_form_for`, `short_form_for`).

Are these MECE? When should each be used?

## Fix

Document the distinction in `models/concepts/RelatedConcept.lutaml`:

```
class RelatedConcept {
  definition {
    A typed relationship from the current concept (or designation)
    to another concept.

    Lives at one of two levels:

    1. **Concept-level** — `ManagedConcept#related`. Use for
       semantic relationships between concepts as a whole
       (deprecates, supersedes, broader, narrower, equivalent,
       etc.). Wire field: top-level `related:` array.

    2. **Designation-level** — `Designation#related`. Use for
       relationships between specific designations of a concept
       (abbreviated_form_for, short_form_for). Wire field:
       `designations[].related` array.

    Both levels use the same RelatedConceptType enum, but the
    applicable types differ. Designation-level relationships are
    restricted to designation-level types (ISO 10241-1 §5.4.2).
  }
  ...
}
```

Also add a row to the README's "Related concepts" section table.

## Verification

```bash
grep -A8 "class RelatedConcept" models/concepts/RelatedConcept.lutaml
```

## Status: pending
