# Glossarist Ontology Suite

A comprehensive OWL ontology for the [Glossarist concept model](https://github.com/glossarist/concept-model) implementing ISO 10241-1 terminology management.

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
│   ├── relationship-type.ttl     # Glossarist-specific relationship types
│   ├── designation-type.ttl      # Designation types (expression/abbreviation/symbol/...)
│   ├── term-type.ttl             # ISO 12620 term types (24 values)
│   ├── grammar-gender.ttl        # Grammatical gender
│   └── grammar-number.ttl        # Grammatical number
└── shapes/
    └── glossarist.shacl.ttl      # SHACL validation shapes
```

## Design Principles

1. **SKOS alignment** — `gloss:Concept` is a `skos:Concept`. Designations use `skosxl:Label`. Instant interoperability with SKOS tooling.

2. **SKOS-XL for designations** — Each designation is both a `gloss:Designation` subclass and a `skosxl:Label`, with `skosxl:literalForm` carrying the text. Preferred designations are linked via `skosxl:prefLabel`, non-preferred via `skosxl:altLabel`.

3. **ISO 25964 reuse** — Hierarchical relationship subtypes (`broaderGeneric`/`narrowerGeneric`, `broaderPartitive`/`narrowerPartitive`, `broaderInstantial`/`narrowerInstantial`) are reused directly from `iso-thes:` rather than duplicated.

4. **SKOS taxonomies for enums** — All enumeration values are `skos:Concept` individuals in `skos:ConceptScheme` collections, not OWL named individuals.

5. **No blank nodes** — All instances are identifiable with proper IRIs.

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
└── gloss:Symbol
    ├── gloss:LetterSymbol
    └── gloss:GraphicalSymbol
```

### Supporting Classes

`Pronunciation`, `GrammarInfo`, `DetailedDefinition`, `ConceptSource`, `ConceptReference`, `RelatedConcept`, `ConceptDate`, `NonVerbalRepresentation`, `DesignationRelationship`, `Citation`, `Locality`.

## Relationship Property Mapping

Standard relationships are reused directly:

| Glossarist type | RDF property |
|----------------|-------------|
| broader / narrower | `skos:broader` / `skos:narrower` |
| broader_generic | `iso-thes:broaderGeneric` |
| broader_partitive | `iso-thes:broaderPartitive` |
| broader_instantial | `iso-thes:broaderInstantial` |
| equivalent | `skos:exactMatch` |
| close_match | `skos:closeMatch` |
| broad_match | `skos:broadMatch` |
| see / related | `skos:related` |

Glossarist-specific relationships are defined as `gloss:` properties:

`gloss:deprecates`, `gloss:supersedes`, `gloss:compares`, `gloss:contrasts`, `gloss:sequentiallyRelated`, `gloss:spatiallyRelated`, `gloss:temporallyRelated`, `gloss:hasHomograph`, `gloss:hasFalseFriend`, `gloss:abbreviatedFormFor`, `gloss:shortFormFor`.

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
  dcterms:language "eng" ;
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
