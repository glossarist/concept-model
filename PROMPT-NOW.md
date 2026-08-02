# PROMPT-NOW: Unified inline mention syntax + terminology disambiguation + non-concept entity canonical IDs

> **Context:** concept-browser is implementing a strict DATA/DEPLOYMENT boundary for inline content. This prompt proposes five concept-model changes that align with that boundary. Self-contained — no need to read concept-browser's TODO.

## Background: the principle

**Dataset authors** write concepts, sources, bibliography, figures, tables, formulas, and inline mentions. They do not know where their dataset will be deployed, what other datasets will be co-deployed, or what URLs will be used.

**Deployers** write `site-config.yml` — they register datasets, declare URI patterns, optionally add routing entries for external datasets. They never edit dataset content.

**Concept-browser** resolves every cross-reference at runtime via a fixed cascade. The same YAML works in any deployment without modification.

## P1: Terminology disambiguation in the ontology

### The problem

The current ontology uses `gloss:NonVerbalEntity` as an abstract base for two categorically different things:

- **Non-verbal designations of concepts** (`gloss:NonVerbalRepresentation`) — e.g., the symbol `kg` designates the concept "kilogram". These are properties OF concepts. A designation modality.
- **Non-concept entities** (`gloss:SharedNonVerbalEntity` = Figure, Table, Formula) — standalone dataset entities that are NOT concepts and NOT designations. A figure illustrates a concept; it does not designate it.

Calling both "non-verbal" is a category error. Non-verbal refers to the modality of expression. A figure is not a "non-verbal" anything — it's a non-concept entity that happens to use visual modality.

### Proposed change

Rename `gloss:SharedNonVerbalEntity` → `gloss:NonConceptEntity`. Keep `gloss:NonVerbalRepresentation` for designations. Update `rdfs:label` and `rdfs:comment` accordingly.

```turtle
# BEFORE
gloss:SharedNonVerbalEntity a owl:Class ;
  rdfs:subClassOf gloss:NonVerbalEntity ;
  rdfs:label "Shared Non-Verbal Entity"@en .

# AFTER
gloss:NonConceptEntity a owl:Class ;
  rdfs:subClassOf gloss:NonVerbalEntity ;  # keep for backward-compat subsumption
  rdfs:label "Non-Concept Entity"@en ;
  rdfs:comment """
    A dataset-shared entity that is NOT a concept: Figure, Table, Formula.
    Has stable dataset-wide identity. Distinct from NonVerbRep (which is
    a concept-local non-verbal designation) and from NonVerbalRepresentation
    (which is a designation modality of a concept).
  """@en .

# Deprecated alias for backward compat
gloss:SharedNonVerbalEntity owl:equivalentClass gloss:NonConceptEntity .
```

Existing instances keep working via the `rdfs:subClassOf` chain and `owl:equivalentClass` alias.

**Files to update:**
- `ontologies/glossarist.ttl` (lines ~1497–1532)
- `schemas/v3/figure.yaml`, `table.yaml`, `formula.yaml` (comments/descriptions)
- `README.adoc` (the non-verbal entities section, ~line 564+)
- `docs/design/*.md` if they reference the old terminology

---

## P2: Canonical URN for non-concept entities

### The problem

Today, Figure/Table/Formula have dataset-local `id` fields only. They cannot be referenced cross-dataset. If cie-eilv wants to cite a figure from a co-deployed IEV dataset, there's no mechanism.

For concepts, cross-dataset resolution works because `Citation::Ref.source` is a canonical identifier that the deployment maps via `ref`/`refAliases`/`uriPatterns`. Non-concept entities need the same mechanism.

### Proposed change

Add optional `gloss:urn` property to `gloss:NonConceptEntity`:

```turtle
gloss:urn a owl:DatatypeProperty ;
  rdfs:label "urn" ;
  rdfs:comment """
    Optional canonical URN for cross-dataset resolution. When present,
    inline mentions like {{fig:urn:...}} can route to this entity via
    the deployment's uriPatterns — same cascade as concept URN resolution.
    When absent, the entity is resolved intra-dataset only.
  """@en ;
  rdfs:domain gloss:NonConceptEntity ;
  rdfs:range xsd:string .
```

Schema change (`schemas/v3/figure.yaml`):

```yaml
properties:
  id:
    type: string
    description: Dataset-local identifier (matches filename).
  urn:
    type: string
    description: |
      Optional canonical URN for cross-dataset resolution.
      When present, {{fig:urn:...}} mentions route via the
      deployment's uriPatterns. Example: urn:iso:std:iec:60050:figure:diagram_3
  identifier:
    type: string
    description: Human-readable display identifier (optional).
```

Same for `table.yaml` and `formula.yaml`.

**Impact:** enables future `{{fig:urn:...}}` cross-dataset entity resolution. Intra-dataset `{{fig:id}}` continues to work unchanged.

---

## P3: Unified inline mention syntax specification

### The problem

Inline mentions currently have two competing syntaxes:
- `{{kind:target}}` — the new form (`{{cite:id}}`, `{{urn:...}}`, `{{fig:id}}`)
- `<<target, caption>>` — AsciiDoc xref form, historically overloaded for bibliography lookups AND non-verbal entity xrefs

This is confusing for authors and impossible to validate consistently.

### Proposed change

Document `{{kind:target[, label]}}` as the canonical inline mention form. Enumerate all supported kinds:

| Kind | Example | Target | Cross-dataset? |
|---|---|---|---|
| `cite` | `{{cite:sourceId}}` | ConceptSource in same concept's `sources[]` | YES (via origin.ref canonical identifier) |
| `urn` | `{{urn:iso:std:iso:704}}` | Canonical URN → concept | YES |
| `fig` | `{{fig:diagram_3}}` | Figure entity in same dataset | No (today); YES if entity has `urn` (P2) |
| `table` | `{{table:units}}` | Table entity | No / YES (with urn) |
| `formula` | `{{formula:ohm_law}}` | Formula entity | No / YES (with urn) |
| `bib` | `{{bib:ref_1}}` | Bibliography entry (case-3-only, no underlying concept) | No |
| `link` | `{{link:https://example.com}}` | External URL (canonical, deployment-independent) | N/A — external to all datasets |
| `image` | `{{image:src, alt}}` | Inline image embed (local or remote) | N/A |
| (none) | `{{measurement unit}}` | Designation match in same dataset | No |
| (none) | `{{112-01-10}}` | Numeric ID in same dataset | No |

**Deprecation policy for `<<target, caption>>`:**
- Recognized as a legacy alias during migration.
- Maps to `{{fig/table/formula:target, caption}}` only (the legitimate AsciiDoc xref use case for non-concept entities).
- Does NOT map to bibliography or concept citations (those were misuses).
- Emit a deprecation warning when encountered.
- Remove in a future major version.

**Deliverable:** Add `docs/design/inline-mentions.md` documenting the full syntax, the kind table, and the deprecation policy.

---

## P4: Bibliography schema clarity

### The problem

`schemas/v3/bibliography.yaml` doesn't clearly distinguish between two use cases:
1. **Pure bibliographic records** (papers, external standards not deployed as concept datasets) — the intended use.
2. **Concept citations misencoded as bibliography entries** — a misuse where dataset authors put IEV concept IDs in `bibliography.yaml` instead of using `ConceptSource` with structured `origin.ref`.

### Proposed change

Strengthen the schema description and add validation:

```yaml
# schemas/v3/bibliography.yaml
properties:
  bibliography:
    type: array
    description: |
      Ordered list of bibliographic references.

      IMPORTANT: Each entry should be a PURE bibliographic record —
      a paper, standard, or external document that is NOT a concept
      in any deployed dataset. If the referenced thing IS a concept
      (e.g., an IEV entry), use a ConceptSource with structured
      origin.ref instead. Bibliography entries are for case-3-only
      references that have no underlying concept dataset.
    items:
      type: object
      required: [id, reference]
      properties:
        id:
          type: string
          description: |
            Entry identifier, dataset-unique. MUST NOT be a concept ID.
            If this ID matches a concept ID in the same dataset, the
            entry should probably be a ConceptSource instead.
```

Add a validation rule (in the validator suite) that warns when a `BibliographyEntry.id` matches a concept `id` in the same dataset.

---

## P5: New mention kinds (`link`, `image`) + raw-HTML rejection

### The problem

Concept text today sometimes contains raw HTML (`<a href>`, `<img>`) for external links and image embeds. This is brittle, bypasses the renderer, has no accessibility contract, and breaks the data/deployment boundary (raw HTML can embed deployment-specific URLs).

### Proposed change

1. Formally define `link` and `image` kinds in the mention grammar (P3 above).

2. Add validation that rejects raw HTML in concept text content:

```yaml
# In the validator suite
- rule: no-raw-html-in-concept-text
  description: |
    Concept text must use typed mention syntax ({{link:}}, {{image:}})
    instead of raw HTML (<a>, <img>, <iframe>). Raw HTML bypasses
    the renderer and breaks the data/deployment boundary.
  severity: warning
  check: |
    Scan definition/note/example content for HTML tags.
    Flag: <a, <img, <iframe, <script, <style, <embed, <object.
    Suggest: {{link:URL, label}} for links, {{image:src, alt}} for images.
```

3. Update example fixtures to demonstrate the new syntax.

---

## Summary of files to touch

| File | Changes |
|---|---|
| `ontologies/glossarist.ttl` | P1: rename SharedNonVerbalEntity → NonConceptEntity. P2: add gloss:urn property. |
| `schemas/v3/figure.yaml` | P2: add optional `urn` field. P4: strengthen description. |
| `schemas/v3/table.yaml` | Same as figure.yaml. |
| `schemas/v3/formula.yaml` | Same as figure.yaml. |
| `schemas/v3/bibliography.yaml` | P4: strengthen description, add "not a concept ID" guidance. |
| `docs/design/inline-mentions.md` | P3: NEW file documenting the unified syntax. |
| `README.adoc` | P1: terminology update. P3: syntax reference. |
| `spec/validators/` | P4: bibliography-vs-concept-ID validation. P5: raw-HTML validation. |

## Coordination

- **glossarist-js** needs parseMention to recognize `link`, `image`, `bib` kinds (parallel prompt).
- **glossarist-ruby** needs the same parser extension (parallel prompt).
- **concept-browser** wires the resolvers once the libraries ship the new parse output.
- A **shared contract test fixture** (a concept with every kind of mention) should be authored here and consumed by all three libraries + concept-browser.
