# Inline Mentions — Implementation & Usage Guide

> **Status:** Proposal — for glossarist-js, glossarist-ruby, and
> concept-browser implementation teams.
>
> **Depends on:** concept-model PR #89 (fully declarative grammar),
> docs/design/inline-mentions.md (specification).

## 1. For API implementors (glossarist-js, glossarist-ruby)

### 1.1 Parser contract

Each library exports a `parseMentions(text)` function that scans a
string for `{{...}}` patterns and returns an array of parsed mention
objects. Invalid mentions produce errors — they are never silently
passed through.

#### Input

```text
"A {{concept:IEV:702-02-07}} is defined in {{cite:IEC:60050-102, IEC 60050}}."
```

#### Output

```json
[
  {
    "kind": "text",
    "content": "A "
  },
  {
    "kind": "concept",
    "target": {
      "type": "dataset_qualified",
      "dataset": "IEV",
      "id": "702-02-07"
    },
    "label": null,
    "raw": "{{concept:IEV:702-02-07}}",
    "start": 2,
    "end": 27
  },
  {
    "kind": "text",
    "content": " is defined in "
  },
  {
    "kind": "cite",
    "target": {
      "type": "dataset_qualified",
      "dataset": "IEC",
      "id": "60050-102"
    },
    "label": "IEC 60050",
    "raw": "{{cite:IEC:60050-102, IEC 60050}}",
    "start": 43,
    "end": 77
  },
  {
    "kind": "text",
    "content": "."
  }
]
```

Text between mentions is returned as `kind: "text"` segments so the
renderer can interleave text and mentions without re-scanning.

#### Target parsing rules

The target (everything after `kind:` and before optional `, label`)
is parsed into a structured object:

| Target text | Parsed as | Structured shape |
|-------------|-----------|------------------|
| `urn:iec:std:iec:60050:702-02-07` | URN | `{ type: "urn", urn: "urn:iec:std:iec:60050:702-02-07" }` |
| `IEV:702-02-07` | Dataset-qualified | `{ type: "dataset_qualified", dataset: "IEV", id: "702-02-07" }` |
| `ISO:10241-1:2011` | Dataset-qualified (last colon splits) | `{ type: "dataset_qualified", dataset: "ISO", id: "10241-1:2011" }` |
| `diagram_3` | Plain entity ID | `{ type: "entity_id", id: "diagram_3" }` |
| `https://example.com` | URL | `{ type: "url", url: "https://example.com" }` |
| `figures/img.svg` | File path | `{ type: "path", path: "figures/img.svg" }` |

**Colon splitting:** for `DATASET:ID`, split on the LAST `:`. Everything
before is the dataset name; everything after is the entity ID. This
handles source names with internal colons like `ISO:10241-1:2011`.

#### Validation per kind

The parser validates the target format against the kind. Invalid
combinations throw an `InvalidMentionError` with a clear message:

| Kind | Accepts | Rejects |
|------|---------|---------|
| `concept` | `DATASET:ID`, `URN` | bare ID, URL, path |
| `cite` | `DATASET:ID`, `URN` | bare ID, URL, path |
| `fig` | plain ID, `URN` | `DATASET:ID` (figures don't have dataset-qualified cross-refs — use URN for cross-dataset) |
| `table` | plain ID, `URN` | `DATASET:ID` |
| `formula` | plain ID, `URN` | `DATASET:ID` |
| `bib` | plain ID only | `URN`, `DATASET:ID`, URL |
| `link` | `https://` or `http://` URL | bare text, path, `DATASET:ID` |
| `image` | path or URL | `DATASET:ID`, `URN` |

#### Error type

```typescript
class InvalidMentionError extends Error {
  constructor(
    public readonly raw: string,      // "{{concept:112-01-10}}"
    public readonly reason: string,   // "concept target must be DATASET:ID or URN; got bare ID '112-01-10'"
    public readonly position: number, // character offset in source text
  ) {
    super(`Invalid mention at position ${position}: ${reason}`);
    this.name = 'InvalidMentionError';
  }
}
```

### 1.2 Resolver contract

Each library exports a `resolveMention(mention, context)` function
that takes a parsed mention and a resolution context, returning a
resolved reference or an "unresolved" marker.

#### Resolution context

```typescript
interface ResolutionContext {
  // The current concept (for cite source matching)
  concept?: ManagedConcept;

  // The current dataset name
  datasetName?: string;

  // Lookup a concept by DATASET:ID or URN
  resolveConcept(ref: { dataset: string; id: string } | { urn: string }): Concept | null;

  // Lookup a non-concept entity by plain ID (same dataset)
  resolveEntity(kind: 'fig' | 'table' | 'formula', id: string): NonConceptEntity | null;

  // Lookup a bibliography entry by plain ID (same dataset)
  resolveBibEntry(id: string): BibliographyEntry | null;
}
```

#### Resolution algorithm per kind

**`concept:DATASET:ID`** or **`concept:URN`:**
```
1. If URN: call context.resolveConcept({ urn })
2. If DATASET:ID: call context.resolveConcept({ dataset, id })
3. If found: return { status: "resolved", concept, label }
4. If not found: return { status: "unresolved", target, label }
```

**`cite:DATASET:ID`** or **`cite:URN`:**
```
1. Resolve the concept (same as concept: above)
2. If context.concept exists, search its sources[] for an entry whose
   origin.ref matches { source: dataset, id: entity_id }
3. If a source is found: return { status: "resolved", concept, source, label }
4. If no source: return { status: "resolved", concept, source: null, label }
   (still resolves — no pre-declaration required)
5. If concept not found: return { status: "unresolved", target, label }
```

**`fig:ID`** or **`fig:URN`:**
```
1. If URN: not yet implemented for entity cross-dataset (future P2)
2. If plain ID: call context.resolveEntity("fig", id)
3. If found: return { status: "resolved", entity, label }
4. If not found: return { status: "unresolved", target, label }
```

(Same for `table`, `formula`.)

**`bib:ID`:**
```
1. Call context.resolveBibEntry(id)
2. If found: return { status: "resolved", entry, label }
3. If not found: return { status: "unresolved", target, label }
```

**`link:URL`:**
```
1. Return { status: "external", url, label }
(Always resolves — it's an external URL)
```

**`image:path`** or **`image:URL`:**
```
1. If URL: return { status: "external_image", url, label }
2. If path: return { status: "local_image", path, label }
(Always resolves — the renderer handles missing files)
```

#### Resolved mention shape

```typescript
type ResolvedMention =
  | { status: "resolved"; kind: "concept" | "cite"; concept: Concept; source?: ConceptSource; label: string | null }
  | { status: "resolved"; kind: "fig" | "table" | "formula"; entity: NonConceptEntity; label: string | null }
  | { status: "resolved"; kind: "bib"; entry: BibliographyEntry; label: string | null }
  | { status: "external"; kind: "link"; url: string; label: string | null }
  | { status: "external_image" | "local_image"; kind: "image"; url?: string; path?: string; label: string | null }
  | { status: "unresolved"; kind: string; target: Target; label: string | null };
```

### 1.3 API surface (glossarist-js)

```javascript
// src/mentions/parser.js
export function parseMentions(text) { ... }
// Returns: Segment[] (text + mention segments)
// Throws: InvalidMentionError on invalid syntax

// src/mentions/resolver.js
export function resolveMention(mention, context) { ... }
// Returns: ResolvedMention

export function resolveAll(mentions, context) { ... }
// Returns: ResolvedMention[]

// src/mentions/index.js (barrel export)
export { parseMentions, resolveMention, resolveAll, InvalidMentionError } from './index.js';
```

### 1.4 API surface (glossarist-ruby)

```ruby
# lib/glossarist/mentions/parser.rb
module Glossarist
  module Mentions
    autoload :Parser,   "glossarist/mentions/parser"
    autoload :Resolver, "glossarist/mentions/resolver"

    class InvalidMentionError < StandardError
      attr_reader :raw, :reason, :position
    end

    module Parser
      def self.parse(text) ... # Returns Array<Hash> segments
    end

    module Resolver
      def self.resolve(mention, context) ... # Returns Hash
      def self.resolve_all(mentions, context) ... # Returns Array<Hash>
    end
  end
end
```

---

## 2. For the renderer (concept-browser)

### 2.1 Rendering contract

The renderer receives `ResolvedMention[]` from the library and renders
each according to its status and kind:

| Status | Kind | Render as |
|--------|------|-----------|
| resolved | concept | Inline link `<a href="/concept/uri">label or designation</a>` |
| resolved | cite | Inline link with source badge if `source` is present: `<a href="...">label</a> <sup class="source-badge">[src]</sup>` |
| resolved | fig | Inline figure thumbnail with caption: `<figure>...</figure>` |
| resolved | table | Inline table embed |
| resolved | formula | Inline formula render |
| resolved | bib | Bracketed citation: `[1] Author, Title` |
| external | link | External link with icon: `<a href="..." target="_blank">label ↗</a>` |
| external_image | image | `<img src="..." alt="label">` |
| local_image | image | `<img src="/dataset/path" alt="label">` |
| unresolved | * | Plain text with dashed underline + tooltip: `<span class="unresolved" title="...">label or raw</span>` |

### 2.2 Unresolved rendering

Unresolved mentions should NOT be hidden. They render as plain text
with a visual indicator (dashed underline + hover tooltip showing the
target that couldn't be resolved). This makes authoring errors visible
without breaking the page.

### 2.3 Interaction

- Concept/cite links: navigate to the concept page (in-page if same
  dataset, new tab if cross-dataset)
- Fig/table/formula: expand inline or open in a modal
- Link: open in new tab with rel="noopener noreferrer"
- Image: render inline at natural size (responsive max-width)

---

## 3. For users (dataset authors)

### 3.1 Quick reference card

```
┌─────────────────────────────────────────────────────────────┐
│ INLINE MENTION SYNTAX — QUICK REFERENCE                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ {{concept:DATASET:ID}}          Link to a concept            │
│ {{concept:IEV:702-02-07}}                                     │
│                                                              │
│ {{cite:DATASET:ID}}             Cite a concept as a source   │
│ {{cite:IEV:702-02-07, IEV 702-02-07}}                        │
│                                                              │
│ {{fig:ID}}                      Embed a figure               │
│ {{fig:diagram_3, Figure 3: Signal flow}}                    │
│                                                              │
│ {{table:ID}}                    Embed a table                │
│ {{table:units}}                                              │
│                                                              │
│ {{formula:ID}}                  Embed a formula              │
│ {{formula:ohm_law}}                                          │
│                                                              │
│ {{bib:ID}}                      Cite a bibliography entry    │
│ {{bib:ref_1, ISO 704:2022}}                                  │
│                                                              │
│ {{link:URL}}                    External link                │
│ {{link:https://example.com, Example Site}}                  │
│                                                              │
│ {{image:path, alt}}             Inline image                 │
│ {{image:figures/wave.svg, Sine wave}}                       │
│                                                              │
│ URN variant (cross-dataset universal):                       │
│ {{concept:urn:iec:std:iec:60050:702-02-07}}                 │
│ {{cite:urn:iso:std:iso:704:2022}}                           │
│ {{fig:urn:iec:std:iec:60050:figure:diagram_3}}              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Worked examples

#### Citing a concept as a source

You're writing a note that references IEV 702-02-07:

```yaml
notes:
  - content: "See {{cite:IEV:702-02-07, IEV 702-02-07}} for the definition of signal."
```

If you have a matching `ConceptSource` in your `sources[]`:
```yaml
sources:
  - type: authoritative
    origin:
      ref: { source: IEV, id: "702-02-07" }
```
The citation carries the source metadata (type, status, modification).
If you DON'T have a source, the citation still resolves as a plain
concept link — no pre-declaration required.

#### Linking to a concept (not as a source)

```yaml
examples:
  - content: "This is similar to {{concept:VIM:112-02-09, measurement result}}."
```

No source metadata. Just a clickable cross-reference.

#### Embedding a figure

```yaml
definition:
  - content: "The geometry is shown in {{fig:mixed-reflection, Figure 7c}}."
```

The figure `mixed-reflection` lives at `figures/mixed-reflection.yaml`
in your dataset. The renderer shows the caption "Figure 7c" and
embeds the image inline.

#### External link

```yaml
notes:
  - content: "Details at {{link:https://www.iso.org/standard/38109.html, ISO 704}}."
```

Renders as a clickable link opening in a new tab.

#### Cross-dataset URN

When you know the canonical URN but not the dataset-qualified ID:

```yaml
notes:
  - content: "Defined per {{cite:urn:iso:std:iso:704:2022, ISO 704:2022}}."
```

The deployment's `uriPatterns` in `site-config.yml` routes the URN
to the canonical source.

### 3.3 Common errors and fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `missing kind prefix` | Wrote `{{measurement unit}}` or `{{112-01-10}}` | Add kind: `{{concept:VIM:112-01-10}}` |
| `must be DATASET:ID or URN; got bare ID` | Wrote `{{cite:sourceId1}}` (local ID) | Use canonical: `{{cite:IEV:702-02-07}}` |
| `concept target must be DATASET:ID or URN` | Wrote `{{concept:112-01-10}}` | Add dataset: `{{concept:VIM:112-01-10}}` |
| `link target must be https:// or http://` | Wrote `{{link:/internal/page}}` | Use full URL: `{{link:https://...}}` |
| `bib entries do not have URNs` | Wrote `{{bib:urn:...}}` | Use plain ID: `{{bib:ref_1}}` |
| `unknown kind 'ref'` | Wrote `{{ref:IEV:702-02-07}}` | Use `cite` or `concept`: `{{cite:IEV:702-02-07}}` |
| `Raw HTML rejected` | Wrote `<a href="...">` or `<img src="...">` | Use `{{link:...}}` or `{{image:...}}` |
| `Deprecated syntax` | Wrote `<<target, caption>>` | Use `{{fig:target, caption}}` |

### 3.4 What NOT to write

```text
{{measurement unit}}              ← no kind; REJECTED
{{112-01-10}}                     ← no kind; REJECTED
{{cite:src1}}                     ← local ID; REJECTED
{{concept:112-01-10}}             ← bare concept ID; REJECTED
{{link:/page}}                    ← not a URL; REJECTED
{{bib:urn:...}}                   ← bib has no URN; REJECTED
<<fig_3, caption>>                ← deprecated; REJECTED
<a href="...">text</a>            ← raw HTML; REJECTED
<img src="..." alt="...">         ← raw HTML; REJECTED
```

### 3.5 The one rule to remember

**Every mention is `{{kind:target}}`.** The `kind` says what type of
thing you're referencing. The `target` is the canonical identifier
(never a local alias, never bare text). If in doubt, qualify with the
dataset name: `DATASET:ID`.

---

## 4. Implementation checklist

### glossarist-js

- [ ] `src/mentions/parser.js` — `parseMentions(text)` returning segments
- [ ] `src/mentions/resolver.js` — `resolveMention(mention, context)`
- [ ] `src/mentions/index.js` — barrel export
- [ ] `src/mentions/types.ts` — TypeScript interfaces (Segment, Mention, ResolvedMention)
- [ ] `test/mentions/parser.test.js` — parse tests (valid + rejection)
- [ ] `test/mentions/resolver.test.js` — resolution tests (per kind)

### glossarist-ruby

- [ ] `lib/glossarist/mentions.rb` — namespace + autoloads
- [ ] `lib/glossarist/mentions/parser.rb` — `Mentions::Parser.parse(text)`
- [ ] `lib/glossarist/mentions/resolver.rb` — `Mentions::Resolver.resolve(mention, context)`
- [ ] `lib/glossarist/mentions/invalid_mention_error.rb` — error class
- [ ] `spec/unit/mentions/parser_spec.rb`
- [ ] `spec/unit/mentions/resolver_spec.rb`

### concept-browser

- [ ] Consume parsed mentions from glossarist-js
- [ ] Wire resolver with vocabulary store + concept index
- [ ] Render resolved mentions per the rendering contract (section 2.1)
- [ ] Render unresolved mentions with dashed underline + tooltip
- [ ] Handle click interactions (concept navigation, external links, figure modals)
- [ ] `/learn/mentions` page with the quick reference card for authors

### Shared contract test fixture

- [ ] `schemas/v3/examples/_mentions/concept-with-all-mention-kinds.yaml`
  — a concept with one of every valid mention kind in its definition
  text, consumed by all three libraries + concept-browser as a
  cross-implementation contract test
