# Inline Mentions — Unified Syntax Specification

## Overview

Glossarist concept text (definitions, notes, examples) may contain
inline mentions — typed references to other concepts, sources,
figures, tables, formulas, bibliography entries, external links,
or embedded images.

All inline mentions use the unified syntax:

```
{{kind:target}}
{{kind:target, label}}
```

Where `kind` declares what the target is, and `target` is an
identifier, URN, or URL. The optional `label` overrides the display
text at render time.

## Supported kinds

| Kind | Example | Resolves to | Cross-dataset? |
|------|---------|-------------|----------------|
| `cite` | `{{cite:src1}}` | ConceptSource in same concept's `sources[]` (by `source.id`) | YES (via `origin.ref` canonical identifier) |
| `urn` | `{{urn:iso:std:iso:704}}` | Canonical URN → concept (deployment's `uriPatterns` cascade) | YES |
| `fig` | `{{fig:diagram_3}}` | Figure entity in same dataset (by `id`) | No (today); YES if entity has `urn` (P2) |
| `table` | `{{table:units}}` | Table entity in same dataset (by `id`) | No / YES (with `urn`) |
| `formula` | `{{formula:ohm_law}}` | Formula entity in same dataset (by `id`) | No / YES (with `urn`) |
| `bib` | `{{bib:ref_1}}` | Bibliography entry (pure bibliographic record, no underlying concept) | No |
| `link` | `{{link:https://example.com}}` | External URL (canonical, deployment-independent) | N/A — external to all datasets |
| `image` | `{{image:mixed-reflection.svg, Mixed reflection diagram}}` | Inline image embed (local or remote) | N/A |
| (none) | `{{measurement unit}}` | Designation text match in same dataset | No |
| (none) | `{{112-01-10}}` | Numeric concept ID in same dataset | No |

## Resolution cascade

Concept-browser resolves mentions via a fixed cascade at runtime:

1. **Same dataset** — look up by `id` or designation text.
2. **Co-deployed dataset** — if the target matches a `uriPattern` in
   `site-config.yml`, resolve to the co-deployed dataset's concept.
3. **External URN** — if the target is a URN, route via the deployment's
   `uriPatterns` to the canonical source.
4. **Unresolved** — render as plain text with a visual "unresolved"
   indicator.

Dataset authors never need to know which dataset is co-deployed. The
same YAML works in any deployment.

## Deprecation: `<<target, caption>>`

The AsciiDoc xref form `<<target, caption>>` is recognized as a legacy
alias during migration. It maps to `{{fig/table/formula:target, caption}}`
only — the legitimate AsciiDoc xref use case for non-concept entity
references. It does NOT map to bibliography or concept citations (those
were misuses of the xref syntax).

**Migration policy:**
- Recognized as alias during transition.
- Emit a deprecation warning when encountered.
- Remove in a future major version.

## Data/deployment boundary

**Dataset authors** write `{{kind:target}}` mentions using canonical
identifiers (concept IDs, source IDs, entity IDs, URNs). They never
write deployment-specific URLs or internal routing paths.

**Deployers** write `site-config.yml` — they register datasets,
declare URI patterns, and optionally add routing entries for external
datasets. They never edit dataset content.

This separation ensures the same dataset YAML works unchanged across
deployments — a concept authored for an ISO dataset renders correctly
whether deployed standalone, alongside IEV, or in a multi-dataset
register.

## Raw HTML rejection

Concept text must NOT contain raw HTML (`<a>`, `<img>`, `<iframe>`,
etc.). Raw HTML bypasses the renderer, has no accessibility contract,
and breaks the data/deployment boundary by embedding
deployment-specific URLs.

Instead, use typed mention syntax:
- Links: `{{link:https://example.com, Example Site}}`
- Images: `{{image:path/to/image.svg, Alt text}}`

The `check-no-raw-html-in-concept-text` validator flags raw HTML tags
in definition/note/example content.
