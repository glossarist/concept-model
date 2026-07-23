# PartitiveRelation design

This is the canonical design rationale for the `PartitiveRelation`
model. Originally authored as a planning document during the
hyperedge rollout; published here so consumers can cite it.

## Why

The VIM concept-relationship diagrams encode information that the
binary-only `RelatedConcept` model cannot represent:

1. **One-to-many partitive relationships as a single relationship.** A
   bracket-rake notation on the diagram says "this concept is the
   comprehensive whole, and these N concepts together compose it as
   parts." Splitting the rake into N binary `broader_partitive` edges
   loses the "this is one rake" invariant.

2. **Plurality markers on the rake.** VIM diagrams use:
   - a close-set **double line** at the receiver end to say "several
     partitive concepts **of a given type** are involved" (a type-shared
     plurality claim)
   - a **broken line** to say "such plurality is uncertain"

3. **Completeness (complete vs partial).** A rake whose backline
   ends with a tooth is **complete**; a rake with a backline
   continuing without a tooth is **partial**.

## ISO terminology

ISO 704 / 1087-1 / 12620 provide canonical role names:

| Role | ISO 12620 name |
|------|---------------|
| comprehensive concept | superordinate concept partitive |
| partitive concept | subordinate concept partitive |
| the relation itself | partitive relation |
| siblings within a rake | coordinate concepts |

Partitives within one PartitiveRelation are **coordinate concepts** —
they share the comprehensive AND the **criterion of subdivision**
(ISO 12620).

## Design

    PartitiveRelation
      +comprehensive: ConceptRef [1]
      +partitives: PartitiveMember [2..*]
      +completeness: Completeness [0..1]            # default: complete
      +plurality: TypeSharedPlurality [0..1]
      +criterion: LocalizedString [0..1]            # subdivision criterion

    PartitiveMember
      +ref: ConceptRef [1]
      +certainty: MemberCertainty [0..1]            # default: confirmed

    TypeSharedPlurality
      +is_shared: Boolean [1..1]                    # ISO 704 close-set double line
      +is_uncertain: Boolean [0..1]                 # ISO 704 broken line
      +shared_type: ConceptRef [0..1]               # Glossarist extension

Wired into `ManagedConcept` as `+partitive_relations:
PartitiveRelation [0..*]`.

## Why a separate model (not extending RelatedConcept)

Three alternatives were considered.

### A. Extend `RelatedConcept` with `refs: ConceptRef [0..*]`

Rejected: semantics muddied. `RelatedConcept` is binary in
ISO 10241-1 / SKOS / ISO 25964.

### B. Generalize to a single `HyperedgeRelationship`

Rejected: YAGNI. Only partitive rakes need n-ary semantics today.

### C. (Chosen) `PartitiveRelation` as its own class

- Backward compatible — existing binary `related` entries parse
  unchanged.
- Clear semantics.
- Open for extension: if hierarchical or associative relations
  ever need n-ary form, they get their own classes.

## MECE responsibilities

| Concept class              | Owns                                                       | Does NOT own                                      |
|----------------------------|------------------------------------------------------------|---------------------------------------------------|
| `RelatedConcept` (binary)  | One-to-one typed links between concepts                    | Plurality, completeness, joint-decomposition claims |
| `PartitiveRelation`        | One-to-many whole/part decomposition with metadata         | Non-partitive relationships                       |
| `ConceptReference`         | Domain/section classification (typed)                      | Concept-to-concept semantic relationships         |
| `ConceptSource`            | Bibliographic provenance                                   | Concept-to-concept relationships                  |

## OCP strategy

Adding new n-ary relation types (e.g., `SequentialRelation` for
ISO 12620 sequential concept systems) in the future goes through:

1. Add a new `XRelation` class to the model.
2. Wire it as `+x_relations` on `ManagedConcept`.
3. Add a new extractor in the data pipeline.
4. Add a new rendering branch in the UI.

No existing class opens for modification.

## Complete vs partial: data shape

### Complete example

    partitive_relations:
      - comprehensive: { source: VIM, id: "112-02-09" }
        partitives:
          - ref: { source: VIM, id: "112-02-10" }
          - ref: { source: VIM, id: "112-03-26" }
        completeness: complete
        plurality:
          is_shared: true
        criterion:
          eng: measurement result composition

Asserts: **2.9 is composed of exactly 2.10 and 2.26; they share a
type; no other partitives exist.**

### Partial example

    partitive_relations:
      - comprehensive: { source: VIM, id: "112-01-03" }
        partitives:
          - ref: { source: VIM, id: "112-01-04" }
            certainty: confirmed
          - ref: { source: VIM, id: "112-01-05" }
            certainty: confirmed
          - ref: { source: VIM, id: "112-01-22" }
            certainty: possible
        completeness: partial
        criterion:
          eng: quantity classification

Asserts: **1.3 has at least 1.4 and 1.5 as partitives (confirmed);
1.22 might be a partitive (possible); other partitives may also
exist.**

## Coexistence with binary `has_part` / `is_part_of`

The binary `related_concept_type` enum still contains `has_part`,
`is_part_of`, `broader_partitive`, `narrower_partitive`. These
remain valid for simple pairwise assertions.

Use `PartitiveRelation` when:
- The decomposition has 2+ partitives AND membership is jointly
  significant (a "rake"), OR
- Type-shared plurality applies, OR
- Completeness is meaningful, OR
- Per-partitive certainty is needed, OR
- The criterion of subdivision should be recorded

Use a binary edge when:
- The assertion is a single pairwise "X has part Y" with no joint
  claim

Both representations can coexist. The
`check-binary-has-part-redundancy` validator warns when binary
`has_part` edges duplicate PartitiveRelation assertions.

## ExternalConcept (status: external)

PartitiveRelations (and binary RelatedConcepts) may reference
ExternalConcepts — concepts we reference but don't define
ourselves. ISO 704 calls these "parenthetic terms"; we use the
semantic name `ExternalConcept` (a ManagedConcept with
`status: external`).

When another dataset defining the external concept is loaded, the
collection manager adds a `provided_by` binary edge from the
ExternalConcept to the defining concept.

## Performance considerations

- PartitiveRelations are rare (~5–10 per dataset based on VIM).
- The build pipeline emits a parallel `partitive_relations.json`.
- Stats counts both binary edges and n-ary relations separately
  to avoid double-counting.

## Extraction trigger for a base `Relationship` class

**SequentialRelation** (ISO 12620 sequential concept systems) is
the most likely addition.

**Extraction trigger:** when **three** n-ary relation types exist,
extract a base `Relation` class with common fields. If only one or
two exist, do not extract.
