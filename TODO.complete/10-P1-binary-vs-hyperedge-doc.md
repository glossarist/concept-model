# 10 — P1: Document binary `has_part` vs `PartitiveHyperedge` overlap

## Problem

`gloss:hasPart` is now both:

1. An object property on `PartitiveHyperedge` (one of N parts in a
   hyperedge decomposition), and
2. A `related_concept_type` enum value (`has_part`) for binary edges.

Authors can express the same part-of fact two ways with no
consistency check. CHANGELOG acknowledges "no automatic
consolidation" but the model definitions don't warn authors.

## Fix

### In `models/concepts/RelatedConceptType.lutaml`

Update the `has_part` and `is_part_of` definitions:

```
has_part {
  definition {
    The current concept has the related concept as a part (ISO 19135).

    Binary form. For one-to-many decompositions where membership or
    diagram notation is jointly significant, use PartitiveHyperedge
    instead — see models/concepts/PartitiveHyperedge.lutaml.
  }
}
```

### In `models/concepts/PartitiveHyperedge.lutaml`

Update the class definition preamble:

```
class PartitiveHyperedge {
  definition {
    A hyperedge relating one comprehensive (whole) concept to one or
    more partitive concepts as a SINGLE relationship.

    Used when the source diagram depicts a partitive decomposition
    whose membership is jointly significant. For simple pairwise
    "X has part Y" assertions, prefer the binary has_part /
    is_part_of edge (RelatedConceptType). Hyperedges and binary
    edges coexist without automatic consolidation.
    ...
  }
  ...
}
```

## Verification

```bash
grep -A3 "has_part {" models/concepts/RelatedConceptType.lutaml
grep -A2 "PartitiveHyperedge" models/concepts/PartitiveHyperedge.lutaml | head -5
```

## Status: pending
