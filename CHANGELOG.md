# Changelog

All notable changes to the Glossarist concept-model are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

See [RELEASE_NOTES.md](RELEASE_NOTES.md) for per-release consumer impact details
and [RELEASE_PROCESS.md](RELEASE_PROCESS.md) for the release checklist.

## [Unreleased]

### Changed
- **BREAKING**: Replaced flat `Multiplicity` enum (5 values) with
  MECE decomposition into `PartitivePresence` (2 values: required,
  optional) and `PartitiveCount` (3 values: exactly_one, at_least_one,
  multiple). Each partitive now carries `presence` + `count` fields.
  6 combinations, 5 valid (optional + at_least_one collapses to
  optional_multiple and is rejected by the schema).
- **BREAKING**: PartitiveMember no longer has `multiplicity` field.
  See docs/design/partitive-relation.md for the new model.

### Added
- `PartitivePresence` and `PartitiveCount` LUTAML enums.
- New SKOS taxonomies `partitive-presence` and `partitive-count`.
- `gloss:presence` and `gloss:count` ontology properties.
- Negative example 10: invalid `optional + at_least_one` combination.
- Examples 30, 31, 32 updated to use presence/count instead of
  multiplicity.

### Removed
- `Multiplicity` LUTAML enum (replaced by PartitivePresence +
  PartitiveCount).
- `gloss:multiplicity` ontology property.
- `ontologies/taxonomies/multiplicity.ttl` (replaced by
  partitive-presence.ttl + partitive-count.ttl).

## Earlier v3 changes
- Renamed `at_least_one` to `compulsory_at_least_one` for clarity.
- ISO 704:2022 correction: multiplicity + is_delimiting replaces
  the prior TypeSharedPlurality + MemberCertainty design.
- See git log for full history.

## Earlier v2 changes
- PartitiveHyperedge renamed to PartitiveRelation (ISO terminology).
- Per-partitive MemberCertainty, TypeSharedPlurality, etc.
- ExternalConcept, provides/provided_by, criterion field.
- See git log for full history.
