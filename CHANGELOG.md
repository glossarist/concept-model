# Changelog

All notable changes to the Glossarist concept-model package are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — Workstream A: Streamline SSOT (TODO.streamline/01)

- **Prefix settlement**: standardized on `skosxl:` for SKOS-XL across
  `glossarist.ttl`, `glossarist.shacl.ttl`, and the JSON-LD context.
  The `xl:` prefix is no longer declared anywhere in the canonical
  artifacts. Downstream consumers (glossarist-ruby, glossarist-js) must
  follow.
- **`ontologies/prefixes.ttl`**: single source of truth for prefix
  declarations. Every Turtle/JSON-LD/TBX serializer imports this file
  verbatim.
- **Codegen (`scripts/gen-predicates.mjs`)**: emits TypeScript and Ruby
  predicate-constant modules from `ontologies/glossarist.context.jsonld`.
  Output is committed (`dist/js/`, `dist/ruby/`) so consumers don't need
  Node installed to use the gem (and vice versa).
- **npm package `@glossarist/concept-model` 0.1.0**: initial publish.
  Exposes PRED constants, type-safe `Predicate` union, `PREFIXES` map,
  and the raw ontology artifacts via subpath exports.
- **Ruby gem `glossarist-concept-model` 0.1.0**: initial publish.
  Mirrors the npm package. Built via `rake gen` which runs the codegen
  and syncs output into `lib/`.
- **Spec coverage**: prefix discipline, JSON-LD ↔ prefixes.ttl sync,
  TS ↔ Ruby output agreement, codegen output integrity.

### Open follow-ups (deferred to subsequent PRs)

- SHACL shape coverage audit for missing constraints (A4)
- `gloss:hasDefinition` ↔ `skos:definition` dual emission decision (A6)
- Inline mention node ontology (K7)
- Provenance (`prov:wasGeneratedBy`) header shape (J1)
