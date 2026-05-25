## Concept

Filename: `concepts/02bafb0f-2f09-541c-9224-5dedcf4f9a8e.yaml`

```yaml
# data related to the concept
data:
  identifier: '939' # An identifier for the concept being discussed.

  # List of all localizations for the concept
  # The format is <3 digit language code>: <id of the localized-concept>
  localizedConcepts:
    ara: 19bb3553-fc74-535f-9ee8-c2db597d9269
    deu: f27b0718-0a9e-5602-85d4-33952af2f91b
    eng: c1b210f5-21ac-5a8b-8bf3-a34e5de7bddb
    kor: 61361462-65ba-59f4-9f25-31796bb38578
    rus: 8d61d10d-18a3-5888-be8e-ba7c0f480957
    spa: 886155b6-7158-5de2-822d-400f6d20fada
    swe: 7da14dec-ff6c-5e1e-807f-8611f946f1aa

# Date and time when the concept was accepted.
dateAccepted: 2023-04-17

# A UUID for the concept
id: 02bafb0f-2f09-541c-9224-5dedcf4f9a8e

# List of all the related concepts
related: []

# Status of the concept
status: valid
```

## Localized Concept

Filename: `localized-concepts/c1b210f5-21ac-5a8b-8bf3-a34e5de7bddb.yaml`

```yaml
# data related to the concept
data:

  # Authoritative source for current localized concept.
  # This can also be added below in the sources section with type `authoritative`
  authoritativeSource:
  - {}

  # Different dates related to this localized concept
  dates:
  - date: '2010-06-15T00:00:00.000Z'
    type: accepted

  # Definitions list for this localized concept
  definition:
  - content: sensor that detects and collects all of the data for an image (frame / rectangle) at an instant of time

  # List of examples
  examples: []

  # Identifier
  id: 939

  # 3 digit language code for this localized concept
  language_code: eng

  lineage_source_similarity: '1'

  # List of notes for the this localized concept
  notes: []

  # Release version of the current localization
  release: '2'

  # Review date for the current localized concept
  # This can also be added in dates section above
  reviewDate: 2018-09-01

  # Review decision date for the current localized concept
  reviewDecisionDate: 2018-09-01

  reviewDecisionEvent: Publication of ISO 19130-1:2018(E)

  # Review decision for the localized concept
  review_decision: accepted

  # Review notes for this localized concept
  # Can be added in notes section above
  review_decision_notes: Authoritative reference changed from ISO/TS 19130:2010 to
    ISO 19130-1:2018(E), 3.28. Lineage source added as ISO/TS 19130:2010(E)

  # Review status for this localized concept
  review_status: final

  # Relationships at the localization level (DATA cross-cutting)
  related: []

  # List of sources for the current localized concept
  sources:
  # Authoritative source for the current localized concept
  - origin:
      clause: '3.28'
      link: https://www.iso.org/standard/66847.html
      ref: ISO 19130-1:2018
    # Type of the source
    type: authoritative
  - origin:
      ref: ISO/TS 19130:2010(E)
    # Type of the source
    type: lineage

  # List of terms used for this localized concept
  terms:
  - designation: frame sensor
    # normative status of the current designation(term).
    normative_status: preferred
    # type of the current designation(term).
    type: expression

# Date when this localization was accepted
# can also be writtent in dates list format as mentioned above.
dateAccepted: 2023-04-17

# ID of the current localized concept
id: c1b210f5-21ac-5a8b-8bf3-a34e5de7bddb

# status of the current localized concept
status: valid
```

## Designation Types (7)

The V2 YAML format supports seven designation types forming a MECE hierarchy:

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
`type`, `language` (ISO 639), `script` (ISO 15924), `system` (ISO 24229), `international`,
`absent`, `pronunciation`, `sources`, `term_type`, `related`, `register`.

### Expression example

```yaml
terms:
- designation: frame sensor
  normative_status: preferred
  type: expression
  usage_info: used in remote sensing
  grammar_info:
  - number: singular
    gender: neuter
    part_of_speech: noun
```

### Abbreviation example

```yaml
terms:
- designation: WHO
  normative_status: admitted
  type: abbreviation
  acronym: true
  term_type: abbreviation
```

### Symbol example

```yaml
terms:
- designation: "Ω"
  normative_status: preferred
  type: symbol
  international: true
  term_type: symbol
```

### Prefix example

```yaml
terms:
- designation: "kilo"
  normative_status: admitted
  type: prefix
```

### Suffix example

```yaml
terms:
- designation: "itis"
  normative_status: admitted
  type: suffix
```

## Relationship Types (32)

Typed semantic links between concepts. The full type enum covers four standards:

| Category | Standard | Types |
|----------|----------|-------|
| Lifecycle | ISO 10241-1 | `deprecates`, `supersedes`, `superseded_by` |
| Hierarchical | ISO 10241-1 / ISO 25964 | `broader`, `narrower` |
| Generic hierarchy | ISO 25964 (BTG/NTG) | `broader_generic`, `narrower_generic` |
| Partitive hierarchy | ISO 25964 (BTP/NTP) | `broader_partitive`, `narrower_partitive` |
| Instantial hierarchy | ISO 25964 (BTI/NTI) | `broader_instantial`, `narrower_instantial` |
| Equivalence | ISO 10241-1 / ISO 25964 / SKOS | `equivalent`, `exact_match` |
| SKOS mapping | SKOS | `close_match`, `broad_match`, `narrow_match`, `related_match` |
| Comparative | ISO 10241-1 | `compare`, `contrast` |
| Associative | ISO 10241-1 / ISO 25964 | `see`, `related_concept`, `related_concept_broader`, `related_concept_narrower` |
| Spatiotemporal | ISO 25964 / TBX | `sequentially_related_concept`, `spatially_related_concept`, `temporally_related_concept` |
| Lexical | ISO 12620 / TBX | `homograph`, `false_friend` |
| Designation-level | ISO 10241-1 | `abbreviated_form_for`, `short_form_for` |

### Example

```yaml
related:
- type: broader
  content: "complex system"
  ref:
    source: "IEC"
    id: "102-03-02"
- type: exact_match
  content: "exact cross-vocabulary match"
  ref:
    source: "VIM"
    id: "JCGM-200"
- type: deprecated
  content: "old deprecated term"
  ref:
    source: "IEC"
    id: "102-03-11"
```

## Grammar Info

The `grammar_info` field on expression-type designations supports:

* `part_of_speech`: one of `noun`, `verb`, `adj`, `adverb`, `preposition`, `participle`
* `gender`: one or more of `m`, `f`, `n`, `c` (common)
* `number`: one or more of `singular`, `dual`, `plural`, `mass`, `other_number`

```yaml
grammar_info:
- part_of_speech: noun
  gender: n
  number: singular
```

## Register

The `register` field on designations indicates the usage level (ISO 12620 / TBX-Linguist):

| Value | Description |
|-------|-------------|
| `colloquial_register` | Used in everyday informal speech |
| `neutral_register` | Neither formal nor informal; standard usage |
| `technical_register` | Used in technical or specialist contexts |
| `in_house_register` | Used within an organization but not publicly |
| `bench_level_register` | Used in legal or judicial contexts |
| `slang_register` | Very informal, non-standard usage |
| `vulgar_register` | Coarse or taboo language |

```yaml
terms:
- designation: pronto
  type: expression
  register: slang_register
```

## Multi-Level Sources (DATA)

Sources (`gloss:hasSource`) are a cross-cutting DATA concern that can appear at five levels. In YAML, sources at each level use the same `sources` key:

| Level | Where |
|-------|-------|
| Concept | Top-level `sources` in concept YAML |
| Localization | `data.sources` in localized concept YAML |
| Designation | `terms[].sources` |
| Definition | `definition[].sources` |
| Non-verbal rep | `non_verb_rep[].sources` |

```yaml
# Concept-level source (e.g., a governance document)
sources:
- origin:
    ref: ISO 19130-1:2018
  type: authoritative
```

## Multi-Level Relationships (DATA)

Relationships (`gloss:hasRelatedConcept`) can appear at concept, localization, and designation levels:

```yaml
# Concept-level relationship (top-level)
related:
- type: broader
  ref:
    source: IEC
    id: "102-03-02"

# Localization-level relationship (inside data:)
data:
  related:
  - type: compare
    ref:
      source: IEC
      id: "103-01-02"

# Designation-level relationship
terms:
- designation: WHO
  type: abbreviation
  related:
  - type: abbreviated_form_for
    ref:
      source: IEC
      id: "881-01-01"
```

## Review Dates as Structured Events (MANAGEMENT)

Review dates are MANAGEMENT events, represented as typed `ConceptDate` entries. The legacy `reviewDate` / `reviewDecisionDate` / `reviewDecisionEvent` fields are supported for backward compatibility but internally stored as:

| Legacy field | ConceptDate type | Notes |
|-------------|-----------------|-------|
| `reviewDate` | `type: review` | Date of review |
| `reviewDecisionDate` | `type: review_decision` | Date of decision |
| `reviewDecisionEvent` | `type: review_decision` | Stored as `event_description` on the same ConceptDate |

The canonical representation uses the `dates` list:

```yaml
dates:
- date: '2010-06-15T00:00:00.000Z'
  type: accepted
- date: '2018-09-01'
  type: review
- date: '2018-09-01'
  type: review_decision
  event_description: Publication of ISO 19130-1:2018(E)
```

Date type values: `accepted`, `amended`, `retired`, `review`, `review_decision`.
