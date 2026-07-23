# 15 — P2: SequentialRelation (future, noted)

## Why this is noted, not implemented

ISO 12620 defines **sequential concept systems** as a concept
system type parallel to partitive/generic/associative. They are
based on spatial and temporal relations. Our current model has
binary spatiotemporal types (`sequentially_related`,
`spatially_related`, `temporally_related`) but no n-ary class.

If the PartitiveRelation pattern works well, a future
SequentialRelation would mirror it for spatial/temporal rakes.
Example: "process P has phases {p1, p2, p3} in sequence."

This is documented for architectural continuity. It is NOT
implemented in v2.

## Proposed future model (sketch)

```ruby
# ISO 12620 sequential concept system relation.
class SequentialRelation
  +antecedent: ConceptRef [1]                  # the prior concept
  +subsequents: SequentialMember [2..*]        # the following concepts
  +relation_kind: SequentialRelationKind [0..1]  # temporal | spatial
  +completeness: Completeness [0..1]           # reuse from PartitiveRelation
  +criterion: LocalizedString [0..1]           # the ordering principle
end

class SequentialMember
  +ref: ConceptRef [1]
  +position: Integer [0..1]                    # 1-based ordinal; optional
  +certainty: MemberCertainty [0..1]           # reuse from PartitiveRelation
end

enum SequentialRelationKind
  temporal                                      # ISO 12620 "sequential"
  spatial                                       # ISO 12620 "spatial"
```

## Open questions for future implementation

1. **Directionality**: SequentialRelation is ordered (p1 → p2 → p3).
   PartitiveRelation is unordered (the rake has no inherent order).
   Should SequentialRelation have a `position` field on each
   member, or rely on array order?

2. **Cyclic sequences**: can a sequence loop back? (e.g., seasonal
   cycles, life cycles)

3. **Overlap with PartitiveRelation**: a temporal decomposition
   (process → phases) could be modeled as either PartitiveRelation
   (criterion: "temporal phases") or SequentialRelation. When is
   each appropriate?

4. **Naming**: ISO 12620 calls these "sequential concept systems."
   Should the class be `SequentialRelation` (mirrors
   PartitiveRelation) or `SequentialConceptSystem` (matches ISO
   terminology)?

## Trigger for implementation

When:
- A real dataset needs n-ary spatial/temporal grouping
- AND the PartitiveRelation pattern has been stable for one
  release cycle

Then implement SequentialRelation by analogy.

## Status: noted (P2 — not implemented in v2)
