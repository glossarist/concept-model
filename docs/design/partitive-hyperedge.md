# PartitiveHyperedge design

This is the canonical design rationale for the `PartitiveHyperedge`
model. Originally authored as a planning document during the
hyperedge rollout; published here so consumers can cite it.

## Why

The VIM concept-relationship diagrams encode information that the
binary-only `RelatedConcept` model cannot represent:

1. **One-to-many partitive relationships as a single relationship.** A
   bracket-rake notation on the diagram says "this concept is the
   comprehensive whole, and these N concepts together compose it as
   parts." Splitting the rake into N binary `broader_partitive` edges
   loses the "this is one rake" invariant — the same comprehensive
   can appear in multiple independent rakes, and the membership of
   each rake is significant.

2. **Plurality markers on the rake.** VIM diagrams use:
   - a close-set **double line** at the receiver end to say "several
     partitive concepts of the same type are involved"
   - a **dashed line** to say "plurality is uncertain"

3. **Enumeration completeness (open vs closed).** A rake whose
   backline ends without ellipsis is **closed** — the listed teeth
   are ALL the parts of the comprehensive. A rake with a trailing
   ellipsis (or dashed extension) is **open** — the listed teeth are
   SOME of the parts; others exist but are not encoded.

   This axis is orthogonal to plurality. A hyperedge can be:
   - closed + double: all parts listed, several of them
   - open + double: some of multiple parts listed
   - closed (no markers): a plain single-type decomposition
   - open (no markers): some parts listed, no plurality claim

## Design

Three model elements alongside the existing `RelatedConcept`:

### `PartitiveEnumeration` enum

- `closed` — the encoded `parts` array is the COMPLETE decomposition
  of the comprehensive. Asserts: "the comprehensive is composed of
  exactly these parts and no others."
- `open` — the encoded `parts` array is a PARTIAL decomposition.
  Asserts: "the comprehensive has at least these parts; other parts
  may exist but are not encoded here."

Default when omitted: `closed`. Authors are encouraged to set
explicitly; absence is read as "all parts encoded."

### `PluralityMarker` enum

- `double` — close-set double line at the receiver. Indicates
  "several partitive concepts of a given type are involved."
- `dashed` — broken/dashed line. Indicates "plurality is uncertain."

Diagram-notation flags, orthogonal to enumeration. Travel with the
hyperedge so the rendering layer can reproduce the source diagram.

### `PartitiveHyperedge` class

```
PartitiveHyperedge
  +comprehensive: ConceptRef [1]                  // the whole
  +parts: ConceptRef [1..*]                       // the parts
  +enumeration: PartitiveEnumeration [0..1]       // default: closed
  +markers: PluralityMarker [0..*]                // diagram notation
  +content: LocalizedString [0..1]                // optional label / note
```

Wired into `ManagedConcept` as `+partitive_hyperedges:
PartitiveHyperedge [0..*]`.

## Why a separate model (not extending RelatedConcept)

Three alternatives were considered.

### A. Extend `RelatedConcept` with `refs: ConceptRef [0..*]`

Make `ref` optional, add multi-ref variant. **Rejected:**

- Semantics muddied. `RelatedConcept` is binary in ISO 10241-1 /
  SKOS / ISO 25964 — every standard it cites models relationships as
  binary edges. Permitting n-ary `refs` on the same class breaks
  consumers that assume `ref` is singular.
- No place for `enumeration` or `markers`. They'd need parallel
  optional fields that are meaningless on binary edges.

### B. Generalize to a single `HyperedgeRelationship`

```
HyperedgeRelationship
  +type: RelatedConceptType
  +members: HyperedgeMember [2..*]   // each with role + ref
  +enumeration: Enumeration [0..1]
  +markers: PluralityMarker [0..*]
```

**Rejected:**

- YAGNI. Only partitive rakes need hyperedge semantics today.
  Hierarchical rakes in VIM are visually similar but semantically
  independent — each narrower stands alone as "is-a" broader, no
  joint claim. Splitting them as binary edges is faithful.
- OCP done right: start with one concrete hyperedge class. If a
  second hyperedge type is needed later, extract the base
  `HyperedgeRelationship` then — the abstraction will be informed
  by two concrete cases instead of speculatively designed from one.

### C. (Chosen) `PartitiveHyperedge` as its own class

Pros:

- Backward compatible — existing binary `related` entries parse
  unchanged.
- Clear semantics — `PartitiveHyperedge` is hyperedge-shaped
  (comprehensive + parts + markers + enumeration); `RelatedConcept`
  stays binary.
- UI can render hyperedges specially without touching the binary-edge
  pipeline.
- Open for extension: if hierarchical or associative hyperedges are
  needed later, they get their own classes or — once two cases exist
  — a shared parent is extracted.

## MECE responsibilities

| Concept class                | Owns                                                        | Does NOT own                                       |
|------------------------------|-------------------------------------------------------------|----------------------------------------------------|
| `RelatedConcept` (binary)    | One-to-one typed links between concepts                     | Plurality, enumeration, joint-decomposition claims |
| `PartitiveHyperedge`         | One-to-many whole/part decomposition with notation markers  | Non-partitive relationships                        |
| `ConceptReference`           | Domain/section classification (typed)                       | Concept-to-concept semantic relationships          |
| `ConceptSource`              | Bibliographic provenance                                    | Concept-to-concept relationships                   |

## OCP strategy

Adding new hyperedge types (hierarchical, associative) in the future
goes through:

1. Add a new `XHyperedge` class to the model.
2. Wire it as `+x_hyperedges` on `ManagedConcept`.
3. Add a new extractor in the data pipeline.
4. Add a new rendering branch in the UI.

No existing class opens for modification.

## Open vs closed: data shape

### Closed example

```yaml
partitive_hyperedges:
  - comprehensive:
      source: urn:oiml:pub:v:2:2012
      id: '2.9'
    parts:
      - source: urn:oiml:pub:v:2:2012
        id: '2.10'
      - source: urn:oiml:pub:v:2:2012
        id: '2.26'
    enumeration: closed
    markers: [double]
    content: "measurement result comprises measured value and uncertainty"
```

Asserts: **2.9 is composed of exactly 2.10 and 2.26, with plurality
(double-line) notation.** Adding a third part would change the
relationship.

### Open example

```yaml
partitive_hyperedges:
  - comprehensive:
      source: urn:oiml:pub:v:2:2012
      id: '1.3'
    parts:
      - source: urn:oiml:pub:v:2:2012
        id: '1.4'
      - source: urn:oiml:pub:v:2:2012
        id: '1.5'
      - source: urn:oiml:pub:v:2:2012
        id: '1.22'
    enumeration: open
    markers: [double, dashed]
```

Asserts: **1.3 has at least 1.4, 1.5, and 1.22 as parts; other
parts may exist; plurality is uncertain (dashed).** Adding a new
part extends the relationship without contradicting it.

## Coexistence with binary `has_part` / `is_part_of`

The binary `related_concept_type` enum still contains `has_part`,
`is_part_of`, `broader_partitive`, `narrower_partitive`. These
remain valid for simple pairwise assertions.

Use `PartitiveHyperedge` when:

- The decomposition has more than two members AND membership is
  jointly significant (a "rake"), OR
- Diagram notation (double / dashed) applies, OR
- Closed/open completeness is meaningful.

Use a binary edge when:

- The assertion is a single "X has part Y" with no joint claim, OR
- The relationship is non-partitive (generic, instantial,
  associative).

Both representations can coexist on the same concept without
automatic consolidation. Authors must choose deliberately per
relationship.

## Performance considerations

- Hyperedges are rare (~5–10 per dataset based on PR #65). No
  scalability concern.
- The build pipeline emits a parallel `hyperedges.json` rather than
  expanding each hyperedge into N binary edges on the fly. This
  keeps `edges.json` binary (existing graph rendering unchanged)
  and lets the UI fetch hyperedges lazily.
- Stats counts both edges and hyperedges separately to avoid
  double-counting.

## Out of scope

- Backfilling `enumeration: closed` on existing binary
  `broader_partitive` edges. Binary edges remain open-by-default
  (they assert one part relationship without claiming exclusivity).
- Generalizing `enumeration` to binary edges as a separate flag.
  Today no standard notation expresses this on binary edges; if a
  need arises, add a separate decorator rather than overloading the
  binary model.
- Hierarchical hyperedges. Each `narrower` in VIM is independent;
  binary edges are faithful.

## Extraction trigger for `HyperedgeRelationship` base class

The current design has a single `PartitiveHyperedge` class. VIM and
ISO 10241-1 diagrams also have other n-ary constructs (generic
instantial, associative-multidimensional, etc.). We deferred
introducing a `HyperedgeRelationship` abstract base class as YAGNI.

**Extraction trigger:** when **three** hyperedge subclasses exist,
do the following refactor:

1. Introduce `HyperedgeRelationship < glossarist:Relationship` with
   the common fields (`comprehensive`, `parts`, `content`).
2. Move `PartitiveHyperedge` under it as a concrete subclass with
   the `enumeration` and `markers` fields specific to partitive
   decomposition.
3. Future hyperedge types (instantial, associative) inherit the base
   and add their own axes.

If only one or two hyperedge types exist, do not extract — the cost
of generalization exceeds the benefit of factoring out
`comprehensive` and `parts`.
