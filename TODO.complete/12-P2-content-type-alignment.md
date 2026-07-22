# 12 — P2: Align `content` type — model vs schema

## Problem

Drift between LUTAML model and JSON Schema:

| Source | Type for `content` |
|--------|-------------------|
| `models/concepts/PartitiveHyperedge.lutaml:58` | `<<BasicDocument>> LocalizedString [0..1]` |
| `schemas/v3/concept.yaml:372-374` | `type: string` |
| `models/concepts/RelatedConcept.lutaml:10` (existing) | `<<BasicDocument>> LocalizedString` |
| `schemas/v3/concept.yaml:141-143` (existing) | `type: string` |

Pre-existing on `RelatedConcept#content`; repeated on the new
`PartitiveHyperedge#content`. Either:
- The model is wrong (it's just a string)
- The schema is wrong (it should be a structured localized text)

The project's I7 invariant (`00-master-plan.md` in glossarist-ruby
TODO.hyperedges) declares: *"content is a localized string (language
→ text hash)."* So the model is right; the schema is wrong.

But fixing the schema is a breaking change for existing consumers
unless we accept both shapes (`oneOf` string or hash).

## Fix

### Step 1: Document the inconsistency

In `schemas/v3/concept.yaml`, add a comment on `related_concept.content`
and `partitive_hyperedge.content`:

```yaml
content:
  type: string
  description: |
    Free-text description of the relationship.

    Note: the LUTAML model declares this as LocalizedString. The
    schema currently accepts a plain string for backward
    compatibility. A future schema version may require the
    structured form `{language: text}`.
```

### Step 2 (follow-up, not blocking): tighten the schema

Use `oneOf` to accept both forms during the transition:

```yaml
content:
  oneOf:
    - type: string
    - type: object
      additionalProperties:
        type: string
      description: Localized text (language code → text).
```

Consumers must accept both. Document in CHANGELOG as a future
deprecation.

## Out of scope for this PR

Step 2 requires coordination with glossarist-ruby and glossarist-js
to ensure both parse the structured form. Defer until the next
minor release.

## Status: pending (Step 1 only for now)
