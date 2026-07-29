# Relations as Files — Architectural Design

## Status

Proposed — 2026-07-29. Implementation: TODO.general-rels.

## Context

Glossarist v3.0 introduced `PartitiveRelation` as a first-class n-ary
concept-system relation. It was bundled inside the concept YAML:

```yaml
# concepts/5-1.yaml
id: "5-1"
data: { ... }
partitive_relations:
  - comprehensive: { ... }
    partitives: [ ... ]
    criterion: { eng: "...", fra: "..." }
```

This bundling was defensible when relations were small structural edges.
It stops being defensible at OIML V 2-200:2010 scale, where one concept
(5.1 measurement standard) has 6 generic hyperedges, each with its own
criterion, sources, and lifecycle.

## Problem

Three concrete problems:

### 1. i18n bloat

A concept like 5.1 has 6 generic relations. Each carries a localized
`criterion` and now also localized `notes` and per-source `modification`
text. At 3 languages × 6 relations × 3 text fields, that's 54+ localized
strings piled into the concept file alongside the concept's own
localized_concepts. The concept file becomes both a structural unit and
a localization unit simultaneously — two concerns, one file.

### 2. Provenance

Every terminological assertion needs its own sources. Currently
PartitiveRelation has no `sources` field. Adding one to the bundled
form makes the concept file even less appropriate.

### 3. Lifecycle independence

A concept can be `valid` while one of its decompositions is `draft`
(newly proposed rake from a recent source). Bundled, the file's status
is ambiguous. Per-file, each relation has its own `status`.

## Design

### Directory layout

```
concepts/
  <id>.yaml                       # ManagedConcept only
relations/
  <comprehensive-id>/
    <criterion-slug>.yaml         # one relation per file
```

### File format

Single relation per file. Same shape as the existing PartitiveRelation
wire format, plus `$id`, `type`, and the new `sources`/`notes`/`status` fields.

```yaml
--- 
$id: 5-1/by-realization-medium
type: generic_relation
status: valid
comprehensive: { source: VIML, id: "5.1" }
completeness: complete
criterion:
  eng: by realization medium
  fra: par milieu de réalisation
members:
  - ref: { source: VIML, id: "5.13" }
    presence: required
    count: exactly_one
sources:
  - type: authoritative
    origin:
      ref: { source: OIML, id: "V 2-200:2010" }
      locality: { type: figure, reference_from: "5.1" }
notes:
  eng: Establishes the realization-medium criterion...
```

### Naming

- **Top-level dir:** `relations/` — generic enough for future types.
- **Per-comprehensive subdir:** `<comprehensive-id>/`.
- **Filename:** criterion slug (kebab-case English).

For criteria without natural English text, use structural slugs
(`by-decomposition-1`) and rely on the localized `criterion` field.

### i18n design

Inline `LocalizedString` (object keyed by ISO 639-3 code). Same pattern
as existing PartitiveRelation#criterion.

Per-language sub-files were considered and rejected. Hyperedge text is
short (criterion is a phrase, notes are 1–2 sentences). Splitting
per-language would 4× file count for marginal translator benefit.

### Discovery

By directory convention. `relations/<id>/` enumerates all decompositions
of `<id>`. No back-reference from concept file — discovery is structural.

### What stays bundled

**Binary `related` edges** stay in concept files. They have at most one
short `content` field. Splitting them would create 10× more files for
no benefit.

## Alternatives considered

### Per-language sub-files

Rejected: hyperedge text is short, doesn't justify the file count.

### Concept-as-directory (concept + relations in one dir)

```
concepts/5-1/
  index.yaml
  relations/
    by-realization-medium.yaml
```

Rejected: mixes concept storage with relation storage. Couples their
lifecycles at the filesystem level. The flat `concepts/<id>.yaml` +
`relations/<id>/<slug>.yaml` separation is cleaner.

### Back-reference index

```yaml
# concepts/5-1.yaml
relations:
  - 5-1/by-realization-medium
  - 5-1/by-governance-level
```

Rejected: redundant with directory structure. Can drift. Convention
over configuration.

## Migration

Clean break — no backward compatibility. Existing `partitive_relations`
arrays in concept files are migrated by `exe/migrate-to-per-file-relations`
to the new per-file format.

## Cross-references

- [Generic Relation Design](generic-relation.md)
- [Abstract N-ary Relation](abstract-nary-relation.md)
- [ISO 704:2022 Mapping](iso704-2022-mapping.md)
