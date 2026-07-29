# Definition Types — Design

## Status

Proposed — 2026-07-29. Implementation: TODO.general-rels.

## ISO 704:2022 §5.3 reference

ISO 704:2022 distinguishes four definition strategies:

1. **Intensional** — genus + differentiae (the standard form)
2. **Extensional** — enumerate instances or species
3. **Partitive** — describe composition (parts of the whole)
4. **Translated** — a definition translated from another language
   (with potential semantic shifts)

## Current state

`DetailedDefinition` carries only `content`, `sources`, `examples`.
The definition's *type* is implicit — readers infer it from prose.

This creates problems:
- Tools can't filter "show me all partitive definitions in this dataset"
- Validators can't check "this concept has a partitive_relations entry
  but no partitive definition — consider adding one"
- Renderers can't apply type-specific styling or labeling

## Design

Add `type` field:

```
DetailedDefinition
  +content:  ParagraphBlock [1..*]
  +type:     DefinitionType [0..1]   # NEW; default: intensional
  +sources:  ConceptSource [0..*]
  +examples: DetailedDefinition [0..*]
```

```
DefinitionType enum:
  - intensional    (default when omitted)
  - extensional
  - partitive
  - translated
```

## Wire format

```yaml
definition:
  - type: intensional
    content: "A measurement unit is a real scalar quantity..."
  - type: partitive
    content: "A measurement standard is composed of a reference
              material, a measuring system, or a material measure."
```

## Validation rules

### `check-definition-coherence` (new, P2)

- Warns when a concept has `partitive_relations` but no `partitive`-typed
  definition — suggests adding one
- Warns when a concept has `generic_relations` but no `intensional`-typed
  definition (genus should appear in intensional definition)
- Errors when `type: translated` is present but no source language is
  indicated (not yet modeled — defer until needed)

### Default handling

When `type` is omitted, the definition is treated as `intensional`.
This is backward-compatible with existing data (no migration needed).

## Why not sub-class

Sub-classing DetailedDefinition into IntensionalDefinition,
ExtensionalDefinition, etc. was considered and rejected:

- The discriminator (type) is enough; the structure is identical
- Sub-classes would force a parser dispatch on wire format
- The validation rules key on the type field, not on type identity

## Future extensions

If a real need arises for type-specific fields (e.g., intensional
definitions gaining a structured `genus: ConceptRef` and
`differentiae: [Characteristic]`), we can add them as optional fields
on DetailedDefinition gated by the type. We do NOT pre-engineer this.

## Acceptance

- `DetailedDefinition.lutaml` has the new `type` field
- `localized-concept.yaml` schema allows `definition[].type`
- A new `definition-type.ttl` SKOS taxonomy
- Updated SHACL shape with valuesFrom constraint
- Updated JSON-LD context with `definition_type` term
