# Changelog

All notable changes to the Glossarist concept-model are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

See [RELEASE_NOTES.md](RELEASE_NOTES.md) for per-release consumer impact details
and [RELEASE_PROCESS.md](RELEASE_PROCESS.md) for the release checklist.

## [Unreleased]

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
