# Glossarist Ontology Suite

A comprehensive OWL ontology for the [Glossarist concept model](https://github.com/glossarist/concept-model). Glossarist builds on and extends multiple ISO standards for terminology management: ISO 10241-1 (terminology entries), ISO 30042/TBX (data exchange), ISO 12620 (data category registry), ISO 25964/SKOS (thesaurus interoperability), and ISO 639/15924/24229 (language/script/system identifiers).

## Namespace

| Prefix | IRI | Purpose |
|--------|-----|---------|
| `gloss:` | `https://www.glossarist.org/ontologies/` | Glossarist-specific classes and properties |
| `skos:` | `http://www.w3.org/2004/02/skos/core#` | Concept scheme, labels, relationships |
| `skosxl:` | `http://www.w3.org/2008/05/skos-xl#` | Reified lexical labels (designations) |
| `iso-thes:` | `http://purl.org/iso25964/skos-thes#` | Hierarchical relationship subtypes |
| `dcterms:` | `http://purl.org/dc/terms/` | Language, bibliographic citation |
| `prov:` | `http://www.w3.org/ns/prov#` | Source provenance |

## File Layout

```
ontologies/
├── prefixes.ttl                  # Canonical prefix declarations (SSOT for all serializers)
├── glossarist.ttl                # Core OWL ontology — classes and properties
├── glossarist.context.jsonld     # JSON-LD @context for the namespace
├── README.md                     # This file
├── reference-docs/               # W3C reference ontology copies
│   ├── skos.ttl                  # SKOS namespace reference
│   ├── skos-xl.ttl               # SKOS-XL namespace reference
│   └── iso-25964-skos-thes.ttl   # ISO 25964 SKOS-Thes reference
├── taxonomies/                   # SKOS ConceptSchemes for enum values
│   ├── concept-status.ttl        # Concept lifecycle status
│   ├── entry-status.ttl          # Localized entry status
│   ├── normative-status.ttl      # Designation normative status
│   ├── source-type.ttl           # Source type (authoritative/lineage)
│   ├── source-status.ttl         # Source status (identical/modified/...)
│   ├── relationship-type.ttl     # 52 relationship types (ISO 10241-1, 19135, 25964, 12620/TBX)
│   ├── designation-type.ttl      # Designation types (expression/abbreviation/symbol/prefix/suffix)
│   ├── term-type.ttl             # ISO 12620 term types (34 values)
│   ├── abbreviation-type.ttl     # Abbreviation formation types (truncation/acronym/initialism/other)
│   ├── date-type.ttl             # Date/event types for lifecycle governance (accepted/amended/retired/review/review_decision)
│   ├── grammar-gender.ttl        # Grammatical gender
│   ├── grammar-number.ttl        # Grammatical number (5 values: singular/dual/plural/mass/other_number)
│   ├── register.ttl              # TBX-Linguist register (7 values)
│   ├── part-of-speech.ttl        # Part of speech (6 values)
│   ├── ordering-method.ttl       # Ordering methods (systematic/mixed/alphabetical)
│   └── concept-reference-type.ttl # Reference types (domain/section/local/designation)
└── shapes/
    └── glossarist.shacl.ttl      # SHACL validation shapes
```

## Design Principles

0. **Canonical prefixes** — `prefixes.ttl` is the single source of truth for prefix bindings. Every serializer (glossarist-ruby, glossarist-js, concept-browser) references this file verbatim. The canonical SKOS-XL prefix is `skosxl:` (per W3C convention); `xl:` is intentionally absent. Do not introduce alternative prefix spellings in downstream consumers.

1. **SKOS alignment** — `gloss:Concept` is a `skos:Concept`. Designations use `skosxl:Label`. Instant interoperability with SKOS tooling.

2. **SKOS-XL for designations** — Each designation is both a `gloss:Designation` subclass and a `skosxl:Label`, with `skosxl:literalForm` carrying the text. Preferred designations are linked via `skosxl:prefLabel`, non-preferred via `skosxl:altLabel`.

3. **ISO 25964 reuse** — Hierarchical relationship subtypes (`broaderGeneric`/`narrowerGeneric`, `broaderPartitive`/`narrowerPartitive`, `broaderInstantial`/`narrowerInstantial`) are reused directly from `iso-thes:` rather than duplicated.

4. **SKOS taxonomies for enums** — All enumeration values are `skos:Concept` individuals in `skos:ConceptScheme` collections, not OWL named individuals.

5. **No blank nodes** — All instances are identifiable with proper IRIs.

6. **DATA vs MANAGEMENT separation** — Terminological content (definitions, designations, sources, relationships) is distinct from register governance (status, lifecycle dates, review events, release). Inspired by TBX (ISO 30042) which separates `<langSec>`/`<termSec>` from `<transactionGrp>`/`<adminNote>`.

7. **Union domains for cross-cutting DATA** — Properties like `gloss:hasSource`, `gloss:hasRelatedConcept`, `gloss:hasDate`, and `gloss:language` use `owl:unionOf` domains because the same semantic property legitimately applies at multiple levels of the model. Designation-level relationships use a dedicated `gloss:hasDesignationRelationship` property (MECE separation from concept-level `gloss:hasRelatedConcept`).

## DATA vs MANAGEMENT Architecture

The ontology separates two orthogonal concerns:

### DATA — terminological content (what the concept IS)

| Concern | Levels | Property |
|---------|--------|----------|
| Sources | Concept, L10n, Designation, Def, NVR | `gloss:hasSource` (5-level union) |
| Relationships | Concept, L10n | `gloss:hasRelatedConcept` (2-level union) |
| Designation relationships | Designation | `gloss:hasDesignationRelationship` → `gloss:DesignationRelationship` |
| Language/script/system | L10n, Designation, Pronunciation | `gloss:language`, `gloss:script`, `gloss:conversionSystem` |
| Definitions/notes/examples/annotations | L10n | `gloss:hasDefinition` / `gloss:hasNote` / `gloss:hasExample` / `gloss:hasAnnotation` |
| Designations | L10n | `skosxl:prefLabel` / `skosxl:altLabel` / `skosxl:hiddenLabel` |
| Normative status | Designation | `gloss:normativeStatus` |
| Term type | Designation | `gloss:hasTermType` |
| Register (usage level) | Designation | `gloss:register` |
| Grammar | Expression | `gloss:hasGrammarInfo` |
| Pronunciation | Designation | `gloss:hasPronunciation` |
| NVR | L10n | `gloss:hasNonVerbalRep` |
| Classification | L10n | `gloss:classification` |
| Domains | Concept | `gloss:hasDomain` |
| Tags | Concept | `gloss:tag` |

### MANAGEMENT — register governance (how the concept is MANAGED)

| Concern | Level | Property |
|---------|-------|----------|
| Concept status | Concept | `gloss:hasStatus` |
| Entry status | L10n | `gloss:hasEntryStatus` |
| Lifecycle events | Concept, L10n | `gloss:hasDate` (2-level union) → `gloss:ConceptDate` |
| Review type | L10n | `gloss:reviewType` |
| Release version | L10n | `gloss:release` |
| Lineage similarity | L10n | `gloss:lineageSimilarity` |
| Identifier | Concept | `gloss:identifier` |

`gloss:ConceptDate` is a MANAGEMENT event with a `gloss:dateType` (accepted, amended, retired, review, review_decision) and optional `gloss:eventDescription`. Review dates are represented as `ConceptDate(type: "review")`, review decisions as `ConceptDate(type: "review_decision", eventDescription: "...")` — not as standalone fields.

## Core Classes

### Concept Management

| Class | Alignment | Maps to (glossarist-ruby) |
|-------|-----------|--------------------------|
| `gloss:Concept` | `skos:Concept` | `ManagedConcept` |
| `gloss:LocalizedConcept` | `skos:Concept` | `LocalizedConcept` |
| `gloss:ConceptCollection` | `skos:Collection` | `ManagedConceptCollection` |

### Designation Hierarchy (MECE)

```
gloss:Designation (skosxl:Label)
├── gloss:Expression
│   └── gloss:Abbreviation
├── gloss:Symbol
│   ├── gloss:LetterSymbol
│   └── gloss:GraphicalSymbol
├── gloss:Prefix
└── gloss:Suffix
```

### Supporting Classes

`Pronunciation`, `GrammarInfo`, `DetailedDefinition`, `ConceptSource`, `Citation`, `CitationRef`, `ConceptRef`, `Reference`, `RelatedConcept`, `DesignationRelationship`, `ConceptDate`, `NonVerbalRepresentation`, `Locality`, `CustomLocality`.

### Citation Architecture (Three MECE Classes)

| Class | Used in | YAML ref shape | Has locality? | Has version? |
|-------|---------|---------------|---------------|--------------|
| `gloss:Citation` | `ConceptSource#origin` | `ref: { source:, id:, version: }` | Yes | Yes (in CitationRef) |
| `gloss:ConceptRef` | `RelatedConcept#ref` | `ref: { source:, id: }` | No | No |
| `gloss:Reference` | domains, references | flat keys | Yes | Yes |

- **Citation** — bibliographic citation with structured `CitationRef` (source + id + version), locality, link, original text, and custom_locality.
- **ConceptRef** — concept link with source + id + optional text. No version, locality, or link.
- **Reference** — typed classification reference for domains and typed references.

## Relationship Property Mapping

Standard relationships are reused directly:

| Glossarist type | RDF property |
|----------------|-------------|
| broader / narrower | `skos:broader` / `skos:narrower` |
| broader_generic | `iso-thes:broaderGeneric` |
| broader_partitive | `iso-thes:broaderPartitive` |
| broader_instantial | `iso-thes:broaderInstantial` |
| equivalent | `gloss:equivalent` (Glossarist-specific, distinct from exact_match) |
| exact_match | `skos:exactMatch` |
| close_match | `skos:closeMatch` |
| broad_match | `skos:broadMatch` |
| see / related_concept | `skos:related` |

Glossarist-specific relationships are defined as `gloss:` properties:

`gloss:deprecates`, `gloss:supersedes`, `gloss:supersededBy`, `gloss:compares`, `gloss:contrasts`, `gloss:sequentiallyRelated`, `gloss:spatiallyRelated`, `gloss:temporallyRelated`, `gloss:hasHomograph`, `gloss:hasFalseFriend`, `gloss:relatedConceptBroader`, `gloss:relatedConceptNarrower`, `gloss:abbreviatedFormFor`, `gloss:shortFormFor`.

## Usage Example

```turtle
@prefix gloss:    <https://www.glossarist.org/ontologies/> .
@prefix skos:     <http://www.w3.org/2004/02/skos/core#> .
@prefix xl:       <http://www.w3.org/2008/05/skos-xl#> .
@prefix iso-thes: <http://purl.org/iso25964/skos-thes#> .
@prefix dcterms:  <http://purl.org/dc/terms/> .

<urn:glossarist:concept:103-01-01> a gloss:Concept, skos:Concept ;
  gloss:identifier "103-01-01" ;
  gloss:hasStatus gloss:status/valid ;
  gloss:hasLocalization <urn:glossarist:l10n:103-01-01-eng> .

<urn:glossarist:l10n:103-01-01-eng> a gloss:LocalizedConcept, skos:Concept ;
  gloss:isLocalizationOf <urn:glossarist:concept:103-01-01> ;
  gloss:language "eng" ;
  skosxl:prefLabel <urn:glossarist:label:103-01-01-eng-pref> ;
  gloss:hasDefinition [
    rdf:value "a concept within a defined scope..."@eng
  ] .

<urn:glossarist:label:103-01-01-eng-pref> a gloss:Expression, iso-thes:PreferredTerm ;
  xl:literalForm "geometric node"@eng ;
  gloss:normativeStatus gloss:norm/preferred .
```

## Validation

SHACL shapes in `shapes/glossarist.shacl.ttl` validate:
- Concept types and required properties
- Designation class hierarchy and property constraints
- Source, citation, and date structure

Use [pySHACL](https://github.com/RDFLib/pySHACL) or [Apache Jena](https://jena.apache.org/) to validate instance data against these shapes.

## License

CC-BY 4.0
