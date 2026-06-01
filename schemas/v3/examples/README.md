# Glossarist Concept Model — YAML Examples

Concrete YAML examples for every feature of the v2 concept model. Each example
is a valid instance against the schemas in `../concept.yaml` (managed concept)
and `../localized-concept.yaml` (localized concept).

Companion files share a numeric prefix and are meant to be read together:
`NN-topic.yaml` is the managed concept, `NN-topic-localized*.yaml` are its
localizations.

## Feature Coverage

| # | Topic | Managed concept | Localized concept(s) |
|---|-------|----------------|---------------------|
| 01 | Minimal concept | `01-minimal-concept.yaml` | `01-minimal-localized.yaml` |
| 02 | Designations (all 7 types + grammar + term_type) | — | `02-designation-expression.yaml`, `02-designation-abbreviation.yaml`, `02-designation-symbol.yaml` |
| 03 | Pronunciation | — | `03-pronunciation.yaml` |
| 04 | Definition, notes, examples | — | `04-definition-notes-examples.yaml` |
| 05 | Domains (classification) | `05-domains.yaml` | `05-domains-localized.yaml` |
| 06 | Related concepts (all 32 types) | `06-related-relationships.yaml` | `06-related-localized.yaml`, `06-related-localized-fra.yaml` |
| 07 | Sources & citations (all features) | `07-sources.yaml` | `07-sources-localized.yaml` |
| 08 | Multi-language / multi-script | `08-multilanguage.yaml` | `08-multilanguage-eng.yaml`, `-ara.yaml`, `-jpn.yaml`, `-rus.yaml` |
| 09 | Non-verbal representations | — | `09-nonverbal.yaml` |
| 10 | Concept references | `10-concept-reference.yaml` | `10-concept-reference-localized.yaml` |
| 11 | Lifecycle & review | `11-lifecycle.yaml` | `11-lifecycle-localized.yaml` |
| 12 | Absent & international designations | `12-absent-designation.yaml` | `12-absent-designation-eng.yaml`, `12-absent-designation-jpn.yaml` |
| 13 | Superseded & deprecated lifecycle | `13-superseded-deprecated.yaml` | `13-superseded-deprecated-localized.yaml` |
| 14 | ISO 12620 term types (34 values) | — | `14-term-types.yaml` |
| 15 | Citation & locality features | — | `15-citation-features.yaml` |
| 16 | Tags (organizational metadata) | `16-tags.yaml` | — |

---

## 01 — Minimal Concept

The smallest valid managed concept and its localization.

**Features:** `id`, `identifier`, `localized_concepts` map, `status`, `date_accepted`, structured `dates`.

## 02 — Designations (7 types + grammar + term_type)

Seven designation types form a MECE hierarchy:

| Type | Extends | Key additions |
|------|---------|---------------|
| `expression` | Base | `prefix`, `usage_info`, `field_of_application`, `grammar_info` |
| `abbreviation` | Expression | `acronym`, `initialism`, `truncation` booleans |
| `symbol` | Base | (none — pure base) |
| `letter_symbol` | Symbol | `text` |
| `graphical_symbol` | Symbol | `text`, `image` |
| `prefix` | Base | A prefix that attaches before a designation |
| `suffix` | Base | A suffix that attaches after a designation |

All types inherit from Base: `designation`, `normative_status`, `geographical_area`,
`language`/`script`/`system`, `international`, `absent`, `pronunciation`, `sources`,
`term_type`, `related` (designation-level), `register` (ISO 12620 / TBX-Linguist).

- **Expression** — `02-designation-expression.yaml`: preferred/admitted/deprecated
  terms, all grammar info options (noun, verb, adj, adverb, preposition, participle;
  gender: m/f/n/c; number: singular/dual/plural), `geographical_area` (US vs GB),
  `usage_info`, `field_of_application`, `term_type` (full_form, variant, entry_term,
  common_name, synonym), designation-level sources.
- **Abbreviation** — `02-designation-abbreviation.yaml`: acronym/initialism/truncation
  booleans, designation-level `related` (abbreviated_form_for, short_form_for).
- **Symbol, letter_symbol, graphical_symbol** — `02-designation-symbol.yaml`:
  international symbols, text/image representations.

## 03 — Pronunciation

Pronunciations attach to individual designations with language, script, country,
and transcription system (ISO 24229). Demonstrates the three-level cascade:
ConceptData defaults → Designation overrides → Pronunciation overrides.

- **`03-pronunciation.yaml`**: Japanese term with Hepburn romanization and IPA
  transcriptions; Hiragana variant with script override.

## 04 — Definition, Notes, Examples

All three use `DetailedDefinition` — text content with optional per-item sources.

- **`04-definition-notes-examples.yaml`**: definition with authoritative source,
  two notes (one with lineage source), and an example.

## 05 — Domains (Classification)

Domains are language-agnostic classification tags. A concept *belongs to*
subject areas — this is not semantic hierarchy.

- **`05-domains.yaml`**: ConceptReference array with `ref_type: "domain"`.
- **`05-domains-localized.yaml`**: Per-language `domain` URI string (relative,
  URN, or URL forms).

## 06 — Related Concepts (All 32 Typed Semantic Relationships)

Typed semantic links between concepts. The full type enum covers four standards:

| Category | Standard | Types |
|----------|----------|-------|
| Lifecycle | ISO 10241-1 | `deprecates`, `supersedes`, `superseded_by` |
| Hierarchical | ISO 10241-1 / ISO 25964 | `broader`, `narrower` |
| Generic hierarchy | ISO 25964 (BTG/NTG) | `broader_generic`, `narrower_generic` |
| Partitive hierarchy | ISO 25964 (BTP/NTP) | `broader_partitive`, `narrower_partitive` |
| Instantial hierarchy | ISO 25964 (BTI/NTI) | `broader_instantial`, `narrower_instantial` |
| Equivalence | ISO 10241-1 / ISO 25964 / SKOS | `equivalent`, `exact_match` |
| Approximate mapping | ISO 25964 / SKOS | `close_match` |
| Cross-vocabulary mapping | SKOS | `broad_match`, `narrow_match`, `related_match` |
| Comparative | ISO 10241-1 | `compare`, `contrast` |
| Associative | ISO 10241-1 / ISO 25964 | `see` |
| Associative subtypes | ISO 25964 / TBX | `related_concept`, `related_concept_broader`, `related_concept_narrower` |
| Spatiotemporal | ISO 25964 / TBX | `sequentially_related_concept`, `spatially_related_concept`, `temporally_related_concept` |
| Lexical | ISO 12620 / TBX | `homograph`, `false_friend` |
| Designation-level | ISO 10241-1 | `abbreviated_form_for`, `short_form_for` |

- **`06-related-relationships.yaml`**: All 27 relationship types at the managed
  concept level, organized by category.
- **`06-related-localized.yaml`**: English `see` relationship at the localization level.
- **`06-related-localized-fra.yaml`**: French `false_friend` (ISO 12620/TBX) —
  a relationship that only exists in one language.

## 07 — Sources & Citations (All Features)

Sources appear at five levels: managed concept, localized concept,
definition/note/example, designation, and non-verbal representation. Each source has:
- `type`: authoritative or lineage
- `status`: 10 values (identical, similar, modified, restyle, context_added,
  generalisation, specialisation, unspecified, related, not_equal)
- `origin`: structured citation with `ref` (always a hash with source/id/version),
  locality, link, original, custom_locality
- `modification`: free-text description of changes

- **`07-sources.yaml`**: Managed concept with authoritative and lineage sources.
- **`07-sources-localized.yaml`**: All 10 source status values, locality ranges
  (reference_from → reference_to), custom_locality, link field, original field,
  modification notes.

## 08 — Multi-Language / Multi-Script

A concept with four localizations demonstrating different scripts and writing systems.

- **`08-multilanguage.yaml`**: Managed concept with eng/ara/jpn/rus map.
- **`08-multilanguage-eng.yaml`**: English (Latn) with expression + abbreviation.
- **`08-multilanguage-ara.yaml`**: Arabic (Arab) with entry_status.
- **`08-multilanguage-jpn.yaml`**: Japanese with Kanji/Kana/Latn variants,
  demonstrating the script cascade and pronunciation overrides.
- **`08-multilanguage-rus.yaml`**: Russian (Cyrl) with transliterated form
  using ISO 24229 conversion system code.

## 09 — Non-Verbal Representations

URI references to external resources (ISO 10241-1 §6.5): images, tables, formulas.
Resources live outside the concept model and are referenced by relative path,
URN, or URL.

- **`09-nonverbal.yaml`**: Three representation types with different URI schemes.

## 10 — Concept References

Typed references to other concepts — local (same glossary) or external (another
registry). `ref_type` values: `local`, `designation`, `urn`, `domain`.

- **`10-concept-reference.yaml`**: Domain references on managed concept.
- **`10-concept-reference-localized.yaml`**: Local, URN, and designation
  references on localized concept.

## 11 — Lifecycle & Review

Status transitions, structured dates, review metadata, release version, and
lineage similarity tracking.

Review dates are MANAGEMENT events — `reviewDate` / `reviewDecisionDate` / `reviewDecisionEvent`
are backward-compatible aliases for typed `ConceptDate` entries (`type: review`,
`type: review_decision` with `event_description`).

- **`11-lifecycle.yaml`**: Managed concept with dates (accepted, amended),
  supersedes relationship.
- **`11-lifecycle-localized.yaml`**: entry_status, dates, review_date/decision,
  lineage_source_similarity, release version.

## 12 — Absent & International Designations

- `absent: true` — explicitly marks that no designation exists in this language.
- `international: true` — symbol valid across all languages (no script override).

- **`12-absent-designation.yaml`**: Managed concept with eng/jpn map.
- **`12-absent-designation-eng.yaml`**: English with normal expression + international symbol.
- **`12-absent-designation-jpn.yaml`**: Japanese with `absent: true` expression,
  international symbol shared, transliterated form as admitted alternative.

## 13 — Superseded & Deprecated Lifecycle

Demonstrates the deprecated/superseded concept lifecycle — a concept that was
replaced by a newer entry. Shows:
- Managed concept with `status: superseded`
- `superseded_by` and `deprecates` relationships
- Localized concept with `entry_status: superseded`
- `normative_status: deprecated` and `normative_status: superseded` on designations
- Retired date

- **`13-superseded-deprecated.yaml`**: Managed concept with superseded_by, deprecates,
  retired date.
- **`13-superseded-deprecated-localized.yaml`**: Deprecated/superseded designations,
  entry_status transitions.

## 14 — ISO 12620 Term Types (34 Values)

ISO 12620 / TBX term_type classification for designations. All 34 values
organized by category:

| Category | Types |
|----------|-------|
| Orthographic/structural | `full_form`, `abbreviation`, `acronym`, `initialism`, `clipped_term`, `short_form`, `transliterated_form`, `transcribed_form`, `truncation`, `variant` |
| Symbolic/formulaic | `symbol`, `formula`, `equation`, `logical_expression`, `mathematical_expression`, `reference_symbol`, `figure_symbol`, `graphic_symbol`, `letter_symbol`, `roman_numeral` |
| Usage/provenance | `code`, `common_name`, `entry_term`, `internationalism`, `international_scientific_term`, `part_number`, `phrase`, `phraseological_unit`, `scientific_name`, `shortcut`, `sku`, `standard_text`, `synonym`, `synonymous_phrase` |

- **`14-term-types.yaml`**: All 34 term_type values demonstrated with contextual
  designations.

## 15 — Citation & Locality Features

All citation and locality features in one example:

| Feature | Shown in |
|---------|----------|
| Structured citation (ref: source + id + version) | multiple sources |
| Locality single reference (clause, section, page, annex) | multiple sources |
| Locality range (reference_from → reference_to) | clause 3.3.3–3.3.5, pages 42–47 |
| Custom locality (name-value pairs) | schema/version/department |
| Link field (URL to source) | ISO 9000, ISO 9001 |
| Original field (transitional) | note source |

- **`15-citation-features.yaml`**: All citation features with contextual examples.

## 16 — Tags (Organizational Metadata)

Tags are plain strings used for grouping and filtering concepts. They are NOT
rendered as terminological domains — that is the role of `domains`.

- **domains**: `ConceptReference` objects — terminological classification (rendered in output)
- **tags**: plain strings — organizational metadata (used for filtering, not rendered)

Example: A concept may belong to domain "103" (IEC 60050-103) and have tags
`["general", "time-scale-units"]` for document organization.

- **`16-tags.yaml`**: Concept with both domains and tags, showing the semantic distinction.

## Cross-Cutting DATA Concerns

The ontology uses union domains for properties that legitimately appear at multiple levels:

| Concern | Property | Levels | Examples |
|---------|----------|--------|----------|
| Sources | `gloss:hasSource` | Concept, L10n, Designation, Def, NVR | 07 (concept, l10n, def, desig), 09 (NVR) |
| Relationships | `gloss:hasRelatedConcept` | Concept, L10n, Designation | 06 (concept, l10n), 02-abbreviation (designation) |
| Dates | `gloss:hasDate` | Concept, L10n | 11, 13 (both levels) |
| Language | `gloss:language` | L10n, Designation, Pronunciation | 03, 08 |

## Schema-to-Example Mapping

The tables below map each schema feature to the example(s) that demonstrate it.

### Managed concept features (`concept.yaml`)

| Feature | Examples |
|---------|----------|
| `id` / `identifier` | 01, 05, 06, 10, 11, 13 |
| `data.uri` | 01 (urn:iec:std:iec:60050-113-01-01) |
| `data.localized_concepts` | 01, 05, 06, 08, 10, 11, 13 |
| `data.domains` | 05, 10 |
| `data.tags` | 16 |
| `data.sources` | 01, 05, 06, 07, 08, 10, 11 |
| `data.related` | (localized-level only) |
| `data.dates` | 11, 13 |
| `status` (7 values) | 01 (valid), 11 (valid), 13 (superseded) |
| `date_accepted` | 01, 06, 11 |
| `related` (32 types) | 06 (all 32), 11 (supersedes), 13 (superseded_by, deprecates) |
| `sources` (concept-level) | 01, 05, 06, 07, 08, 10, 11 |

### Localized concept features (`localized-concept.yaml`)

| Feature | Examples |
|---------|----------|
| `language_code` | 01, 02, 03, 04, 07, 08, 09, 12, 14, 15 |
| `script` (ISO 15924) | 03 (Hani), 08 (Hani, Kana, Latn, Cyrl, Arab) |
| `system` (ISO 24229) | 03 (Hepburn, IPA), 08 (UN:rus-Cyrl:Latn:1993) |
| `entry_status` (4 values) | 08-ara (not_valid), 11 (valid), 13 (superseded) |
| `terms` (7 types) | 02 (expression, abbreviation, symbol, letter_symbol, graphical_symbol), 04, 14 |
| `definition` | 01, 02, 03, 04, 07, 09, 11, 13, 14, 15 |
| `domain` | 05-localized |
| `notes` | 04, 07, 15 |
| `examples` | 04, 07, 15 |
| `sources` | 01, 02, 04, 07, 11, 13 |
| `dates` | 11, 13 |
| `related` | 06-localized, 06-fra |
| `references` | 10-localized |
| `lineage_source_similarity` | 11 |
| `release` | 11, 13 |
| `review_date` / `review_decision_date` / `review_decision_event` | 11 |
| `non_verbal_rep` | 09 |
| `classification` | 11 (admitted) |
| `review_type` | 11 (editorial) |

### Designation features (`localized-concept.yaml` → designation)

| Feature | Examples |
|---------|----------|
| `designation` | all examples |
| `normative_status` (4 values) | 02 (preferred, admitted, deprecated), 12, 13 (deprecated, superseded) |
| `geographical_area` | 02 (US, GB), 14 (US) |
| `type` (7 values) | 02 (5 types shown; prefix/suffix in schema) |
| `language` (per-designation override) | 03 |
| `script` (per-designation override) | 03, 08-jpn, 08-rus |
| `system` (per-designation override) | 08-rus |
| `international` | 02-symbol, 04, 12 |
| `absent` | 12 |
| `pronunciation` | 03, 08-jpn |
| `sources` (per-designation) | 02-expression, 07, 09 |
| `term_type` (34 values) | 08-rus (transliterated_form), 14 (all 34) |
| `related` (designation-level) | 02-abbreviation |
| `prefix` | 02-expression (non-) |
| `usage_info` | 02-expression |
| `field_of_application` | 02-expression |
| `grammar_info` | 02-expression (noun, verb, adj, adverb, preposition, participle; gender; number) |
| `acronym` / `initialism` / `truncation` | 02-abbreviation |
| `text` (letter/graphical symbol) | 02-symbol |
| `image` (graphical symbol) | 02-symbol |

### Citation & source features

| Feature | Examples |
|---------|----------|
| Structured citation (ref: source + id + version) | 01, 04, 07, 15 |
| Locality (single reference) | 07, 15 |
| Locality (range: reference_to) | 07, 15 |
| Custom locality | 07, 15 |
| Link field | 07, 15 |
| Original field | 15 |
| Source type (authoritative/lineage) | all source examples |
| Source status (10 values) | 07 (all 10) |
| Modification | 07, 15 |

### Relationship type coverage

| Category | Type | Example |
|----------|------|---------|
| Lifecycle | `deprecates` | 06, 13 |
| Lifecycle | `supersedes` | 06, 11 |
| Lifecycle | `superseded_by` | 06, 13 |
| Hierarchical | `broader` | 06 |
| Hierarchical | `narrower` | 06 |
| Generic | `broader_generic` | 06 |
| Generic | `narrower_generic` | 06 |
| Partitive | `broader_partitive` | 06 |
| Partitive | `narrower_partitive` | 06 |
| Instantial | `broader_instantial` | 06 |
| Instantial | `narrower_instantial` | 06 |
| Equivalence | `equivalent` | 06 |
| Equivalence | `exact_match` | 06 |
| Mapping | `close_match` | 06 |
| Mapping | `broad_match` | 06 |
| Mapping | `narrow_match` | 06 |
| Mapping | `related_match` | 06 |
| Comparative | `compare` | 06 |
| Comparative | `contrast` | 06 |
| Associative | `see` | 06, 06-localized |
| Associative | `related_concept` | 06 |
| Associative | `related_concept_broader` | 06 |
| Associative | `related_concept_narrower` | 06 |
| Spatiotemporal | `sequentially_related_concept` | 06 |
| Spatiotemporal | `spatially_related_concept` | 06 |
| Spatiotemporal | `temporally_related_concept` | 06 |
| Lexical | `homograph` | 06 |
| Lexical | `false_friend` | 06-localized-fra |
| Designation | `abbreviated_form_for` | 02-abbreviation |
| Designation | `short_form_for` | 02-abbreviation |
