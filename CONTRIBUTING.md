# Contributing to glossarist concept-model

## Architectural layering

The concept-model is **model-driven**: the LUTAML model is the source
of truth. Everything else is derived.

```
models/*.lutaml  ──── source of truth (classes, enums, attributes)
       │
       ├──→ schemas/v3/*.yaml                       (JSON Schema)
       ├──→ ontologies/glossarist.ttl               (OWL ontology)
       ├──→ ontologies/shapes/glossarist.shacl.ttl  (SHACL shapes)
       ├──→ ontologies/glossarist.context.jsonld    (JSON-LD context)
       └──→ ontologies/taxonomies/*.ttl             (SKOS schemes)
```

These artifacts are hand-maintained in sync today. The pure-Ruby
validator suite under `lib/glossarist/concept_model/` catches drift;
CI runs the suite on every PR via
`.github/workflows/validate-schemas.yml`.

## Adding a new enum

1. Add the enum to a `.lutaml` file under `models/concepts/`.
2. Add the enum to `schemas/v3/concept.yaml` under `$defs/`.
3. Add a SKOS taxonomy file under `ontologies/taxonomies/`.
4. Reference the new taxonomy from the relevant SHACL shape
   (`sh:valuesFrom <scheme-URI>`).
5. Add JSON-LD context entries for any new properties.

The CI drift checker will fail the build until all four sites agree.

## Adding a new class

1. Define the class in a `.lutaml` file under `models/`.
2. Add the class to `ontologies/glossarist.ttl` as `owl:Class`.
3. Add a SHACL `sh:NodeShape` targeting the class in
   `ontologies/shapes/glossarist.shacl.ttl`.
4. Add the class to `ontologies/glossarist.context.jsonld`.
5. (Optional) Add example YAMLs under `schemas/v3/examples/`.

The CI coverage checker will fail until every class has a shape and
the context includes every ontology property.

## Before pushing

```bash
make validate     # runs all 7 validators + the RSpec suite
```

Or run individual validators via `bundle exec exe/<name>`:

```bash
bundle exec exe/validate-examples
bundle exec exe/validate-negative-examples
bundle exec exe/validate-ontologies
bundle exec exe/check-enum-drift
bundle exec exe/check-jsonld-context
bundle exec exe/check-shacl-coverage
bundle exec exe/check-lutaml-references
```

To run the RSpec unit tests:

```bash
bundle exec rspec spec/ --format documentation
```

All validators are pure Ruby (`lib/glossarist/concept_model/`) — no
Python tooling required.

## Commit message conventions

- `feat(model): ...` for new model features
- `fix(schema): ...` for schema bug fixes
- `chore(ci): ...` for CI changes
- `docs: ...` for documentation

No AI attribution in commit messages. See `~/.claude/CLAUDE.md` for
the global rule.

## Release process

See `RELEASE_PROCESS.md`. Every PR that touches `ontologies/` or
`schemas/` triggers the release-reminder bot. The maintainer
decides the semver bump after merge.
