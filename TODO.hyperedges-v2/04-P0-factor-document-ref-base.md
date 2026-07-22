# 04 — P0: Factor shared `source+id` shape

## Problem

Three $defs share the same `source` + `id` core but don't factor
it out:

| $def | Has `source` | Has `id` | Extras |
|------|-------------|---------|--------|
| `concept_ref` | ✓ | ✓ | `text` |
| `reference` | ✓ | ✓ | `concept_id`, `version`, `locality`, `link`, `original`, `custom_locality`, `ref_type`, `urn`, `term` |
| `citation_ref` | ✓ | ✓ | `version` |

Each duplicates the `source: { type: string, description: ... }`
and `id: { type: string, description: ... }` stanzas. Field
descriptions diverge slightly (e.g. `source` is described as
"Registry identifier" in one place and "Document series" in
another). DRY violation + drift risk.

## Fix

Add a new `$def`:

```yaml
document_ref_base:
  type: object
  description: |
    Common shape for any reference that points at a document or
    concept identified by (source, id). Specialized by
    `concept_ref`, `reference`, and `citation_ref`.
  properties:
    source:
      type: string
      description: Collection identifier (document series, termbase, vocabulary, registry).
    id:
      type: string
      description: Item identifier within the collection.
  additionalProperties: false
```

Then in each specialized $def:

```yaml
concept_ref:
  allOf:
    - $ref: "#/$defs/document_ref_base"
    - properties:
        text:
          type: string
          description: Target designation text for lexical relationships.
      additionalProperties: false
```

Etc. for `reference` and `citation_ref`.

## Risk

`allOf` with `additionalProperties: false` can interact awkwardly
in JSON Schema Draft 7 (the schema's declared draft). Verify with
the example suite.

Alternative: skip the `allOf` and just keep the duplication, but
add a comment block referencing the canonical shape. Lower-tech,
lower-risk.

## Verification

```bash
python scripts/validate-examples.py
# All examples still pass
```

## Status: pending
