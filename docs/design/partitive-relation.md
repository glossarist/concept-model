# PartitiveRelation design

Canonical design rationale for the `PartitiveRelation` model.

## Why

The VIM concept-relationship diagrams encode information that the
binary-only `RelatedConcept` model cannot represent:

1. **One-to-many membership as a single invariant.** A rake notation
   says "this whole is composed of exactly these parts as one
   relationship."
2. **Per-member multiplicity.** ISO 704:2022 distinguishes compulsory,
   optional, compulsory-multiple, optional-multiple, and at-least-one
   members via line notation (solid/dashed, single/double).
3. **Delimiting parts.** ISO 704:2022 marks parts that behave like
   delimiting characteristics (bold 3x-width line), distinguishing the
   comprehensive from coordinate concepts.
4. **Completeness.** Whether the encoded partitives fitted together
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

    PartitiveMember
      +ref: ConceptRef [1]
      +multiplicity: Multiplicity [0..1]            # default: compulsory
      +is_delimiting: Boolean [0..1]               # default: false

    Multiplicity (ISO 704:2022)
      compulsory          — 1 solid line
      optional            — 1 dashed line
      compulsory_multiple — 2 solid lines
      optional_multiple   — 2 dashed lines
      at_least_one        — 1 solid + 1 dashed line

Wired into `ManagedConcept` as `+partitive_relations:
PartitiveRelation [0..*]`.

### Multiplicity (ISO 704:2022)

Each partitive carries a multiplicity that encodes the diagram line
notation as structured data:

- **compulsory** (default) — must exist in every instance
- **optional** — exists in some instances only
- **compulsory_multiple** — multiple must exist
- **optional_multiple** — multiple may exist
- **compulsory_at_least_one** — at least one must exist (1 solid + 1 dashed line)

### is_delimiting (ISO 704:2022)

A delimiting part behaves like a delimiting characteristic: it
distinguishes the comprehensive from coordinate concepts. Drawn as
a bold (3x-width) line in ISO 704 diagrams.

Example (ISO 704 §5.5.4.2.2): for "optomechanical mouse", the
delimiting parts are mouse ball, x/y-axis rollers, and IR
emitter/sensor — they distinguish it from "mechanical mouse" and
"optical mouse". Mouse button is NOT delimiting (all computer mice
have buttons).

Orthogonal to multiplicity.

### criterion (Glossarist extension)

The principle by which the comprehensive is divided into partitives.
ISO 12620 coordinate-concept coherence: partitives within one
relation share the comprehensive AND the criterion.

Two PartitiveRelations on the same comprehensive with the same
criterion are duplicates (validation error). Two with different
criteria are distinct decompositions.

## When to use PartitiveRelation vs. binary has_part

| Shape | Use when |
|-------|----------|
| Binary has_part / is_part_of | Pairwise assertion, no completeness/multiplicity claim |
| PartitiveRelation | 2+ partitives with completeness, multiplicity, or delimiting |

ISO 704 requires "two or more." A single partitive should be a
binary edge.

Both shapes coexist. The `check-binary-has-part-redundancy`
validator warns when binary edges duplicate a PartitiveRelation.

## Coexistence with binary has_part

The binary `related_concept_type` enum still contains `has_part`,
`is_part_of`, `broader_partitive`, `narrower_partitive`. These
remain valid for simple pairwise assertions.

## ExternalConcept (status: external)

PartitiveRelations may reference ExternalConcepts — concepts we
reference but don't define. Resolves via `provided_by` when a
defining dataset is loaded.

## Extraction trigger for a base Relationship class

When three n-ary relation types exist, extract a base class.
SequentialRelation (ISO 12620 sequential concept systems) is the
most likely addition.
