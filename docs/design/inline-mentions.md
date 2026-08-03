# Inline Mentions — Fully Declarative Syntax (Audited)

> **Principle:** Every mention target is a CANONICAL IDENTIFIER. No
> magic combinations, no bare text, no procedural indirection, no
> implicit "same dataset" assumptions for concepts. The parser
> REJECTS any non-declarative form with a clear error.
>
> A concept or dataset is ENTIRELY ENCAPSULATED — it can reference
> its own entities with plain IDs and external concepts with explicit
> qualifiers, with zero knowledge of the deployment.

## Grammar

```
mention    := "{{" kind ":" target (", " label)? "}}"
kind       := "concept" | "cite" | "fig" | "table" | "formula" | "bib" | "link" | "image"
target     := urn | dataset_qualified | entity_id | url | path
label      := display_text
```

## Target formats (what goes after `kind:`)

| Format | Pattern | Scope | Example |
|--------|---------|-------|---------|
| **URN** | `urn:...` | Universal — resolves via deployment's `uriPatterns` | `urn:iec:std:iec:60050:702-02-07` |
| **Dataset-qualified** | `DATASET:ID` | Cross-dataset — `DATASET` is the canonical dataset name from its `register.yaml` | `IEV:702-02-07` |
| **Plain entity ID** | `id` | Same-dataset — only valid for non-concept entities (fig/table/formula/bib) which live in known locations within the dataset directory structure | `diagram_3` |
| **URL** | `https://...` or `http://...` | External — universal | `https://example.com/page` |
| **Path** | `path/to/file` | Same-dataset — only for `image` kind | `figures/mixed-reflection.svg` |

### Rules

1. **Concepts ALWAYS require dataset qualification or URN.** No bare concept IDs. No same-dataset default. `{{concept:112-01-10}}` is REJECTED — use `{{concept:VIM:112-01-10}}` or `{{concept:urn:iso:std:iso:80000:112-01-10}}`.

2. **Non-concept entities (fig/table/formula/bib) use plain IDs for same-dataset.** These entities live in known locations (`figures/`, `tables/`, etc.) within the dataset, so the ID is unambiguous within the dataset. For cross-dataset, use URN.

3. **The `:` in `DATASET:ID` splits on the LAST colon.** This handles source names that contain colons: `ISO:10241-1:2011` → dataset=`ISO`, id=`10241-1:2011`.

4. **Labels are optional.** When omitted, the renderer uses the resolved entity's display name.

## Kind reference

### `concept` — concept cross-reference

Links to a concept in this or a co-deployed dataset. No source metadata — just a link.

```text
{{concept:IEV:702-02-07}}
{{concept:IEV:702-02-07, signal processing concept}}
{{concept:urn:iec:std:iec:60050:702-02-07}}
```

**Target:** URN or `DATASET:ID`. Bare IDs are REJECTED.

### `cite` — concept citation (with optional source metadata)

Same target format as `concept`, but semantically: "this concept informed my definition." If a matching `ConceptSource` exists in the concept's `sources[]` (matching by `origin.ref.source` + `origin.ref.id`), the citation carries its metadata (status, modification, etc.). If no source exists, it still resolves as a concept reference — no pre-declaration required.

```text
{{cite:IEV:702-02-07}}
{{cite:IEV:702-02-07, IEV 702-02-07}}
{{cite:urn:iec:std:iec:60050:702-02-07}}
```

**Resolution:**
1. Search `sources[]` for `origin.ref` matching `{source: "IEV", id: "702-02-07"}`
2. If found: link with metadata (status, modification, type)
3. If not found: resolve as bare concept reference (same as `concept:` kind)
4. No local source ID indirection — the target IS the canonical identifier

**REJECTED:**
```text
{{cite:sourceId1}}              ← local source ID, not canonical; REJECTED
```

### `fig` — figure entity

Same-dataset figure by plain ID, or cross-dataset by URN.

```text
{{fig:diagram_3}}                         ← same dataset (plain ID)
{{fig:diagram_3, Figure 3: Signal flow}}  ← with label
{{fig:urn:iec:std:iec:60050:figure:diagram_3}}  ← cross-dataset (URN)
```

**Target:** plain entity ID (same-dataset) or URN (cross-dataset).

### `table` — table entity

Same pattern as `fig`.

```text
{{table:units}}
{{table:urn:iso:std:iso:80000:table:units}}
```

### `formula` — formula entity

Same pattern as `fig`.

```text
{{formula:ohm_law}}
{{formula:urn:iso:std:iso:80000:formula:ohm_law}}
```

### `bib` — bibliography entry

Same-dataset bibliography entry by plain ID. Bibliography entries are dataset-local by definition — they are NOT concepts. Cross-dataset bibliography is not supported (use `cite` or `concept` instead).

```text
{{bib:ref_1}}
{{bib:ref_1, ISO 704:2022}}
```

**Target:** plain entity ID only (same-dataset). URN is NOT supported — bibliography entries don't have URNs.

### `link` — external URL

Canonical, deployment-independent URL. ALWAYS `https://` or `http://`.

```text
{{link:https://example.com/page}}
{{link:https://example.com/page, Example Site}}
```

**Target:** URL only. Bare text or internal paths are REJECTED.

### `image` — inline image embed

Local path (relative to dataset root) or remote URL.

```text
{{image:figures/mixed-reflection.svg, Mixed reflection diagram}}
{{image:https://example.com/image.png, Example image}}
```

**Target:** filesystem path or URL. Plain paths are same-dataset only.

## What is REJECTED (magic combinations)

| Pattern | Why rejected | Parser error |
|---------|-------------|--------------|
| `{{measurement unit}}` | No kind prefix; bare text matching | `Missing kind prefix; use {{concept:DATASET:ID}} or {{cite:DATASET:ID}}` |
| `{{112-01-10}}` | No kind prefix; bare numeric | `Missing kind prefix; use {{concept:DATASET:ID}}` |
| `{{cite:sourceId1}}` | Local source ID, not canonical identifier | `cite target must be DATASET:ID or URN; got bare local ID 'sourceId1'` |
| `{{concept:112-01-10}}` | Bare concept ID without dataset qualifier | `concept target must be DATASET:ID or URN; got bare ID '112-01-10'` |
| `{{link:/internal/path}}` | Internal path on link kind | `link target must be https:// or http:// URL` |
| `<<target, caption>>` | Legacy AsciiDoc xref | `Deprecated syntax; use {{fig:target, caption}}` |
| Raw `<a href="...">` | Raw HTML in concept text | `Raw HTML rejected; use {{link:URL, label}}` |
| Raw `<img src="...">` | Raw HTML in concept text | `Raw HTML rejected; use {{image:path, alt}}` |

## Resolution cascade (runtime)

Concept-browser resolves every mention via this fixed cascade:

1. **URN** → route via deployment's `uriPatterns` to the canonical source.
2. **DATASET:ID** → look up the dataset in `site-config.yml`, resolve to its concept/entity.
3. **Plain entity ID** → resolve within the same dataset's directory structure.
4. **URL** → external; open in new tab.
5. **Unresolved** → render as plain text with visual "unresolved" indicator.

Dataset authors never need to know which datasets are co-deployed. The same YAML works in any deployment.

## Data/deployment boundary

**Dataset authors** write `{{kind:canonical_target}}` mentions. They use:
- `DATASET:ID` for concepts (always qualified, even for same-dataset)
- Plain IDs for non-concept entities (fig/table/formula/bib)
- URNs for universal cross-dataset references
- URLs for external links

**Deployers** write `site-config.yml`:
- Register datasets by canonical name
- Declare URI patterns for URN routing
- Never edit dataset content

This separation ensures the same dataset YAML works unchanged across deployments.

## Migration from old syntax

| Old form | New form | Action |
|---------|---------|--------|
| `{{cite:sourceId}}` | `{{cite:SOURCE:ID}}` | Replace local ID with canonical `origin.ref` source:id |
| `{{measurement unit}}` | `{{concept:DATASET:ID}}` | Find the concept by designation, use its canonical ID |
| `{{112-01-10}}` | `{{concept:DATASET:112-01-10}}` | Add dataset qualifier |
| `<<fig_3, caption>>` | `{{fig:fig_3, caption}}` | Replace xref syntax |
| `<a href="...">text</a>` | `{{link:URL, text}}` | Replace raw HTML |
| `<img src="..." alt="...">` | `{{image:path, alt}}` | Replace raw HTML |
