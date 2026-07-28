# PartitiveRelation design

Canonical design rationale for the `PartitiveRelation` model.

## Why

The VIM concept-relationship diagrams encode information that the
binary-only `RelatedConcept` model cannot represent:

1. **One-to-many membership as a single invariant.** A rake notation
   says "this whole is composed of exactly these parts as one
   relationship."
2. **Per-member presence, count, and delimiting.** ISO 704:2022
   distinguishes required/optional, exactly-one/at-least-one/multiple,
   and delimiting/non-delimiting via line notation (solid/dashed,
   single/double, normal/bold).
3. **Completeness.** Whether the encoded partitives fitted together
   constitute the comprehensive (complete) or only some of it (partial).

## ISO terminology

ISO 704:2022 / ISO 1087-1 / ISO 12620 canonical role names:

| Role | ISO name |
|------|----------|
| The whole concept | superordinate concept partitive |
| Each part concept | subordinate concept partitive |
| The relation | partitive relation |
| Siblings in a rake | coordinate concepts |

## Design

    PartitiveRelation
      +comprehensive: ConceptRef [1]
      +partitives: PartitiveMember [2..*]
      +completeness: Completeness [0..1]            # default: complete
      +criterion: LocalizedString [0..1]            # Glossarist extension

    PartitiveMember (MECE: 3 orthogonal dimensions)
      +ref: ConceptRef [1]
      +presence: PartitivePresence [0..1]         # required (default) | optional
      +count: PartitiveCount [0..1]               # exactly_one (default) | at_least_one | multiple
      +is_delimiting: Boolean [0..1]               # false (default) | true

    PartitivePresence (ISO 704:2022)
      required    — 1 solid line (must exist in every instance)
      optional    — 1 dashed line (exists in some instances only)

    PartitiveCount (ISO 704:2022)
      exactly_one  — single line
      at_least_one — 1 solid + 1 dashed (at least one must exist)
      multiple     — double line (two or more)

Wired into `ManagedConcept` as `+partitive_relations:
PartitiveRelation [0..*]`.

### MECE decomposition: 6 combinations, 5 valid

| Presence | Count | Visual | Valid? |
|----------|-------|--------|--------|
| required | exactly_one | 1 solid | yes (compulsory) |
| optional | exactly_one | 1 dashed | yes (optional) |
| required | multiple | 2 solid | yes (compulsory_multiple) |
| optional | multiple | 2 dashed | yes (optional_multiple) |
| required | at_least_one | 1 solid + 1 dashed | yes (compulsory_at_least_one) |
| optional | at_least_one | (invalid — collapses to optional_multiple) | **no** |

The `optional + at_least_one` combination is rejected: if a part is
optional, the at-least-one constraint is vacuous (the part may not
exist at all), so it collapses to `optional_multiple`. The schema
enforces this via an `allOf/if-then` block on `partitive_member`.

### is_delimiting (ISO 704:2022)

A delimiting part behaves like a delimiting characteristic: it
distinguishes the comprehensive from coordinate concepts. Drawn as a
bold (3x-width) line in ISO 704 diagrams.

Example (ISO 704 §5.5.4.2.2): for "optomechanical mouse", the
delimiting parts are mouse ball, x/y-axis rollers, and IR
emitter/sensor — they distinguish it from "mechanical mouse" and
"optical mouse". Mouse button is NOT delimiting (all computer mice
have buttons).

Orthogonal to presence and count.

### criterion (Glossarist extension)

The principle by which the comprehensive is divided into partitives.
ISO 12620 coordinate-concept coherence: partitives within one
relation share the comprehensive AND the criterion.

Two PartitiveRelations on the same comprehensive with the same
criterion are duplicates (validation error). Two with different
criteria are distinct decompositions.

## Why the product space (vs. flat enum)

The previous design used a flat `Multiplicity` enum with 5 values
that was a product space in disguise. Splitting into two
`PartitivePresence` and `PartitiveCount` enums (2+3=5 values) is:

- **DRY**: Adding a new count type (e.g., "range") is a one-value
  addition, not a 5-value cascade.
- **MECE**: Every combination is either valid (5 of 6) or explicitly
  invalid (1 of 6). The invalid one is rejected with a clear error.
- **OCP**: A new count type is additive — no existing values change.
- **ISO alignment**: The two dimensions map directly to ISO 704's
  line-style and line-count notation axes.

## When to use PartitiveRelation vs. binary has_part

| Shape | Use when |
|-------|----------|
| Binary has_part / is_part_of | Pairwise assertion, no completeness/presence/count claim |
| PartitiveRelation | 2+ partitives with completeness, presence, count, or delimiting |

ISO 704 requires "two or more." A single partitive should be a
binary edge.

Both shapes coexist. The `check-binary-has-part-redundancy`
validator warns when binary edges duplicate a PartitiveRelation.

## ExternalConcept (status: external)

PartitiveRelations may reference ExternalConcepts — concepts we
reference but don't define. Resolves via `provided_by` when a
defining dataset is loaded.

## Extraction trigger for a base Relationship class

When three n-ary relation types exist, extract a base class.
SequentialRelation (ISO 12620 sequential concept systems) is the
most likely addition.
