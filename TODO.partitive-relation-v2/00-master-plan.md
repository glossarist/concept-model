# TODO.partitive-relation-v2 — Master plan

## Why this exists

The PartitiveHyperedge contribution (PR #72) shipped with three
architectural problems:

1. **Misnamed**: ISO 704 / 1087-1 / 12620 call this a *partitive
   relation*, not a hyperedge. "Hyperedge" is a graph-theoretic
   framing that confused the data model.

2. **Misstructured**: `enumeration: open|closed` and `markers:
   [double, dashed]` conflated data semantics with diagram
   notation. Per-partitive certainty (b is sure, d is uncertain)
   couldn't be expressed at all.

3. **Missing coherence field**: ISO 12620's *coordinate concept*
   definition requires partitives to share a *criterion of
   subdivision*. Without modeling the criterion, two different
   decompositions of the same comprehensive are indistinguishable.

A follow-up attempt (`feat/content-l10n`) tried to L10N-ify `content`
fields without regard for the LocalizedConcept language-context
rule. It also broke the validators on its own examples.

This plan supersedes both. It is a clean redesign aligned with
ISO 704, ISO 1087-1, and ISO 12620, with clearly-marked
Glossarist extensions where we go beyond the standards.

## Verification methodology

Every "done" backed by:
1. A concrete file change.
2. An executable check (Ruby validator, SHACL, RSpec).
3. A dataset review note for migration-lossy changes.

## Priority definitions

- **P0** — wrong on master now, or blocks the redesign from landing.
- **P1** — coverage gap or downstream consumer impact.
- **P2** — future extension, documented but not implemented in v2.

## Scope

The `concept-model` repo (this one). Cross-repo changes are
documented in `17-downstream-consumer-guide.md` but executed in
their respective repos.

## Architectural invariants enforced

- **I1 (MECE)**: binary `has_part` vs PartitiveRelation scope
  documented. Two relations with same comprehensive + same criterion
  is an error (duplicate decomposition).
- **I2 (OCP)**: adding a new relation type (e.g., SequentialRelation)
  is adding a class, not modifying a switch.
- **I3 (DRY)**: ExternalConcept is a ManagedConcept with a status
  value, not a separate class. Plurality is data, not duplicated in
  notation.
- **I4 (model-driven)**: LUTAML is canonical; schema, SHACL, JSON-LD
  context, taxonomies are derived and CI-checked.
- **I5 (ISO alignment)**: every field name and enum value matches
  the canonical ISO term where one exists. Extensions clearly marked.

## Execution order

```
Phase 1 (P0, model)            : 01 → 02 → 03 → 04 → 05 → 06 → 07
Phase 2 (P1, derived artifacts): 08 → 09 → 10 → 11 → 12 → 13 → 14
Phase 3 (P2, noted extensions) : 15 → 16
Phase 4 (downstream)           : 17 (executed in other repos)
Phase 5 (verification)         : 18
```

## Files in this plan

| # | Priority | Title |
|---|----------|-------|
| 01 | P0 | Rename PartitiveHyperedge → PartitiveRelation; parts → partitives |
| 02 | P0 | enumeration → completeness (semantics unchanged, name aligned) |
| 03 | P0 | markers → plurality (data not notation); add shared_type |
| 04 | P0 | Drop `content` field (structural edges don't carry text) |
| 05 | P0 | Add `criterion: LocalizedString [0..1]` (subdivision criterion) |
| 06 | P0 | ExternalConcept via `status: external` (no new class) |
| 07 | P0 | Add `provides` / `provided_by` to RelatedConceptType |
| 08 | P1 | Migration script (existing data → new shape) |
| 09 | P1 | Rewrite examples 20–23; add new examples |
| 10 | P1 | SHACL shapes for new model |
| 11 | P1 | JSON-LD context updates |
| 12 | P1 | Taxonomies (completeness, member_certainty) |
| 13 | P1 | New validators (criterion coherence, ExternalConcept shape) |
| 14 | P1 | Binary has_part vs PartitiveRelation coexistence rules |
| 15 | P2 | SequentialRelation (future, noted) |
| 16 | P2 | Definition types (future, noted) |
| 17 | — | Downstream consumer guide (glossarist-ruby, glossarist-js, concept-browser, vocab) |
| 18 | — | Verification matrix |
| 19 | — | Summary |

## Architectural decisions (binding for all repos)

### A1. Class name: `PartitiveRelation`

ISO 704 / 1087-1 / 12620 all call this a *relation*. The
"hyperedge" framing was useful for reasoning about the graph
structure but caused naming confusion (Hyperedge sounds
different from Relation, suggesting different semantics).

The graph-theoretic insight (a relation is a set of binary edges
considered as a unit) is preserved in the documentation.

### A2. Cardinality: `partitives [2..*]`

ISO 704 defines partitive relation as connecting a comprehensive
to "two or more" partitives. A single binary `has_part` edge is
not a partitive relation.

### A3. ExternalConcept is a ManagedConcept with `status: external`

Not a new class. Existing tooling (concept lookups, indexing,
cross-references) works unchanged. ExternalConcepts live in the
dataset's `concepts/` directory with minimal data.

### A4. Resolution relationship: `provides` / `provided_by`

Direction: real concept `provides` external concept; external
concept `provided_by` real concept. The link is a binary edge on
the ExternalConcept, established at the collection level
(collection manager or auto-resolution routine).

### A5. Plurality is data, not notation

ISO 704's close-set double line and broken line encode semantic
claims (type-shared plurality, plurality uncertainty). We model
these as data fields (`is_shared`, `is_uncertain`,
`shared_type`). The diagram-notation form is dropped — rendering
is computed from data when needed.

### A6. `criterion` is the coherence field

ISO 12620's *coordinate concept* requires same comprehensive +
same criterion of subdivision. The criterion field makes two
decompositions of the same comprehensive distinguishable.

### A7. `content` is dropped

Structural edges don't carry text. Per-instance notes belong on
the relevant LocalizedConcept or as separate caption structures
(Figure-style), not on the relation.

## Code-quality rules honored

- No `send` to private methods
- No `instance_variable_set/get`
- No `respond_to?` for type checks
- No `require_relative` for internal library code — Ruby autoload
- No doubles in specs — real model instances
- No hand-rolled serialization — lutaml-model only
- No AI attribution

## Out of scope

- Auto-resolution routine for ExternalConcept (separate workstream)
- SequentialRelation class (future, noted in 15)
- Definition types (future, noted in 16)
- Modularization of glossarist.ttl (separate cleanup)
