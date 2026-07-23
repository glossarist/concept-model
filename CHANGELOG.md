# Changelog

All notable changes to the Glossarist concept-model are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

See [RELEASE_NOTES.md](RELEASE_NOTES.md) for per-release consumer impact details
and [RELEASE_PROCESS.md](RELEASE_PROCESS.md) for the release checklist.

## [Unreleased]

### Added
- `PartitiveRelation` model (renamed from `PartitiveHyperedge`):
  ISO 704 / 1087-1 / 12620 partitive relation connecting a
  comprehensive concept to two or more partitive concepts which
  fitted together constitute the comprehensive. See
  `docs/design/partitive-relation.md`.
- `PartitiveMember` class — one member of a PartitiveRelation,
  carrying a ConceptRef plus optional `MemberCertainty`
  (confirmed/possible). Glossarist extension beyond ISO notation.
- `TypeSharedPlurality` class — ISO 704's close-set double line
  and broken line promoted from diagram-notation markers to
  structured data (`is_shared`, `is_uncertain`, optional
  `shared_type`).
- `criterion` field on PartitiveRelation — ISO 12620 coordinate-
  concept coherence dimension. Two relations on the same
  comprehensive with the same criterion are duplicates (error).
- `ExternalConcept` support via new `ConceptStatus#external`
  value. An ExternalConcept is a ManagedConcept referenced from
  this dataset but defined elsewhere; resolves via
  `RelatedConceptType#provided_by` when a defining dataset is
  loaded.
- `provides` / `provided_by` relationship types — resolution edge
  pair established at the collection level by the collection
  manager (replaces `supersedes` / `superseded_by` for this use
  case).
- New SKOS taxonomies: `completeness` (complete/partial),
  `member-certainty` (confirmed/possible).
- New SHACL shapes: `PartitiveMemberShape`,
  `TypeSharedPluralityShape`, `ExternalConceptCoherenceShape`.
- New Ruby validators: `check-partitive-relation-coherence`,
  `check-external-concept-shape`, `check-binary-has-part-redundancy`.
- Migration script: `exe/migrate-to-partitive-relation-v2`
  (supports `--dry-run` and `--backup`).

### Changed
- **BREAKING**: `PartitiveHyperedge` renamed to `PartitiveRelation`
  (ISO terminology). Top-level wire key `partitive_hyperedges` →
  `partitive_relations`.
- **BREAKING**: `parts` (ConceptRef[]) restructured to `partitives`
  (PartitiveMember[]). Each partitive is now `{ref: ConceptRef,
  certainty?: MemberCertainty}` instead of a bare ConceptRef.
- **BREAKING**: `enumeration` renamed to `completeness`; values
  `closed`/`open` renamed to `complete`/`partial`.
- **BREAKING**: `markers` (array of diagram-notation strings)
  replaced by `plurality` (structured TypeSharedPlurality object).
  `markers: [double]` → `plurality: {is_shared: true}`.
  `markers: [dashed]` → `plurality: {is_uncertain: true}`.
  `markers: [double, dashed]` → `plurality: {is_shared: true,
  is_uncertain: true}`.
- **BREAKING**: `content` field removed from PartitiveRelation.
  Structural edges don't carry prose; per-instance notes belong
  on LocalizedConcept or as separate caption structures.
- **BREAKING**: `concept_status` enum gains `external` value;
  ExternalConcept conditional rule forbids definition/sources when
  status is external.
- **BREAKING**: `concept_ref` now accepts three forms via `anyOf`:
  `(source, id, text)` fully resolved, `(source, id)` resolved,
  `(text)` text-only placeholder for ExternalConcept.
- RelatedConceptType enum gains `provides` and `provided_by`
  values.
- `cardinality` of `partitives` tightened from `[1..*]` to
  `[2..*]` (ISO 704 requires "two or more").
- Diagram notation (`markers`) dropped as a separate concept —
  the semantic claims it encoded are now first-class data fields.

### Removed
- `PartitiveHyperedge` LUTAML model (renamed to PartitiveRelation)
- `PartitiveEnumeration` LUTAML model (renamed to Completeness)
- `PluralityMarker` LUTAML model (replaced by TypeSharedPlurality
  class — no enum equivalent)
- `gloss:hyperedgeContent` ontology property
- `ontologies/taxonomies/partitive-enumeration.ttl` (replaced by
  `completeness.ttl`)
- `ontologies/taxonomies/plurality-marker.ttl` (replaced by
  TypeSharedPlurality class)

### Migration
Existing datasets using the v1 shape (`partitive_hyperedges` with
`parts`/`enumeration`/`markers`/`content`) should run:

```bash
bundle exec exe/migrate-to-partitive-relation-v2 --dry-run path/to/concepts/
# review, then:
bundle exec exe/migrate-to-partitive-relation-v2 --backup path/to/concepts/
```

Migration is mostly deterministic; see the script's `--help` for
lossy-case handling.

## [v3.1.0] — 2026-07-05

### Added
- `DatasetRegister`, `Section` classes with full property set in ontology,
  SHACL shapes, and JSON-LD context
- `NonVerbalEntity` hierarchy: `SharedNonVerbalEntity`, `Figure`, `Table`,
  `Formula`, `FigureImage`
- `DesignationRelationship` class for designation-level relationships
  (ISO 10241-1 §5.4.2)
- `ConceptSource#id` for inline `{{cite:id}}` mentions
- `hasScopedExample` property (MECE with concept-level `hasExample`)
  for VIM 1993 style nested examples
- Scoped examples (`examples`) on `DetailedDefinition` in v2/v3 YAML schemas
- `hasChildSection` / `hasParentSection` as `owl:TransitiveProperty` for
  cascading section membership
- New properties: `caption`, `altText`, `description`, `expression`,
  `latexForm`, `content`, `hasSubfigure`, `src`, `format`, `role`
- `ontologies/prefixes.ttl` — canonical prefix declarations (SSOT)
- New SKOS taxonomies: `ordering-method.ttl`, `concept-reference-type.ttl`
- 52 relationship types in `related_concept_type` enum
- `annotations` field on `LocalizedConcept`
- New examples: `18-hierarchical-sections-{register,concept}.yaml`
- `RELEASE_NOTES.md`, `CHANGELOG.md`, `RELEASE_PROCESS.md`

### Changed
- Canonical SKOS-XL prefix changed from `xl:` to `skosxl:` (same IRI:
  `http://www.w3.org/2008/05/skos-xl#`). RDF semantics unchanged.
- `DetailedDefinition` definition text updated to document shape reuse
- `ConceptSource.lutaml` definition updated for cite mention pattern

### Fixed
- Cross-layer MECE violation: SHACL class declarations moved to ontology
- `Figure`/`Table`/`Formula` now inherit through `SharedNonVerbalEntity`
  (matching Lutaml model)
- `NonVerbalRepShape` renamed to `NonVerbalRepresentationShape` targeting
  the existing class
- Missing properties (`expression`, `latexForm`, `content`) declared in ontology
- All inline mention syntax standardized: `{{cite:id}}` (was `{{cite:<id>}}`)

## [v3.0.0] — 2026-06-27

Initial tagged release of the V3 concept model.

[Unreleased]: https://github.com/glossarist/concept-model/compare/v3.1.0...HEAD
[v3.1.0]: https://github.com/glossarist/concept-model/releases/tag/v3.1.0
[v3.0.0]: https://github.com/glossarist/concept-model/releases/tag/v3.0.0
