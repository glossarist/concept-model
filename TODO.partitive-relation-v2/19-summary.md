# 19 — Summary

## Item count

| Priority | Count | Scope |
|----------|-------|-------|
| P0 | 7 | rename, completeness, plurality, drop content, criterion, ExternalConcept, provides/provided_by |
| P1 | 7 | migration, examples, SHACL, JSON-LD context, taxonomies, validators, has_part coexistence |
| P2 | 2 | SequentialRelation (future), Definition types (future) |
| Cross-repo | 1 | Downstream consumer guide |
| Verification | 1 | All green |

## What this plan addresses

The PR #72 follow-ups tried to ship PartitiveHyperedge + a
content-L10N-ification that broke examples. This plan replaces
both with a clean redesign that:

- **Aligns with ISO 704 / 1087-1 / 12620 terminology** — every
  field name and enum value uses canonical terms
- **Models diagram notation as data, not rendering hints** —
  plurality (close-set double line, broken line) becomes structured
  fields with semantic content
- **Adds the missing coherence dimension** — `criterion` field
  distinguishes different decompositions of the same comprehensive
- **Supports external concepts** — `status: external` for concepts
  referenced but not defined; `provided_by` for resolution at the
  collection level
- **Drops the content/caption conflation** — structural edges don't
  carry prose; notes belong on LocalizedConcept

## Architectural invariants enforced

- **I1 (MECE)**: binary `has_part` vs PartitiveRelation scope
  documented; criterion coherence check; ExternalConcept shape
  check
- **I2 (OCP)**: SequentialRelation (future) is adding a class, not
  modifying PartitiveRelation; new validators auto-discover enums
- **I3 (DRY)**: ExternalConcept is a ManagedConcept with a status
  value, not a separate class; plurality is data, not duplicated in
  notation
- **I4 (model-driven)**: LUTAML is canonical; all downstream
  artifacts derived and CI-checked
- **I5 (ISO alignment)**: every field name and enum value matches
  the canonical ISO term; extensions clearly marked in
  documentation and rdfs:comment

## Code-quality rules honored

- No `send` to private methods
- No `instance_variable_set/get`
- No `respond_to?` for type checks
- No `require_relative` for internal library code — Ruby autoload
- No doubles in specs — real model instances
- No hand-rolled serialization — lutaml-model only
- No AI attribution

## Downstream coordination

- **glossarist-ruby + glossarist-js**: must ship v2 support BEFORE
  vocab datasets migrate. Lockstep.
- **concept-browser**: updates after both consumer libs are v2-ready
- **vocab datasets**: migrate via script after concept-browser is
  ready; ~3 hours manual review across 3 VIM datasets
- **External RDF consumers**: versioned context handles transition;
  pin to a tag until code is updated

See `17-downstream-consumer-guide.md` for file-by-file change lists
per consumer.

## Release shape

This is a **minor semver bump** (v3.2.0) for concept-model:
- Additive: new classes, new enum values, new SHACL shapes
- Renames: v1 names removed; v2 names replace them
- Migration path: script + Ruby/JS readers accept v1 shape for one
  release cycle
- Next major release (v4.0.0): drop v1 backward-compat

## Trigger for follow-up work

- **SequentialRelation** (item 15): implement when a real dataset
  needs n-ary spatial/temporal grouping AND PartitiveRelation has
  been stable for one release cycle
- **Definition types** (item 16): implement when a real dataset
  needs to distinguish definition styles for rendering or analysis
- **Auto-resolution routine for ExternalConcept**: implement when
  the manual `provided_by` workflow becomes a bottleneck

## Out of scope

- Performance benchmarks for hyperedge-heavy datasets (separate
  workstream)
- Modularization of `glossarist.ttl` (separate cleanup PR)
- Volume migration of historical vocab datasets beyond VIM (script
  is ready; consumers run as needed)
