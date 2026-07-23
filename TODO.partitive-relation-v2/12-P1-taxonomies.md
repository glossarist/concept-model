# 12 — P1: Taxonomies

## Problem

v2 introduces two new enums (`Completeness`, `MemberCertainty`) and
removes one (`PluralityMarker`). The existing `ConceptStatus` and
`RelatedConceptType` taxonomies gain values. SKOS taxonomy files
must follow.

## Scope

- New: `ontologies/taxonomies/completeness.ttl`
- New: `ontologies/taxonomies/member-certainty.ttl`
- Updated: `ontologies/taxonomies/concept-status.ttl` (add `external`)
- Updated: `ontologies/taxonomies/relationship-type.ttl` (add
  `provides`, `provided_by`)
- Delete: `ontologies/taxonomies/partitive-enumeration.ttl`
- Delete: `ontologies/taxonomies/plurality-marker.ttl`

## Concrete taxonomy files

### completeness.ttl (new)

```turtle
# Completeness Taxonomy
#
# SKOS ConceptScheme for the completeness of a PartitiveRelation.
# Two values: complete (fitted together constitute the comprehensive)
# and partial (other partitives exist beyond those encoded).
#
# Source: ISO 704 (rake backline notation), Glossarist v2.

@prefix gloss:   <https://www.glossarist.org/ontologies/> .
@prefix skos:    <http://www.w3.org/2004/02/skos/core#> .
@prefix dcterms: <http://purl.org/dc/terms/> .

gloss:completeness a skos:ConceptScheme ;
  skos:prefLabel "Completeness"@en ;
  skos:definition "Whether the encoded partitives constitute the whole comprehensive (complete) or only some of it (partial)."@en ;
  dcterms:source <https://www.glossarist.org/schemas/v3/concept> .

<https://www.glossarist.org/ontologies/completeness/complete> a skos:Concept ;
  skos:inScheme gloss:completeness ;
  skos:prefLabel "complete"@en ;
  skos:definition "The encoded partitives fitted together constitute the comprehensive concept. No further partitives exist."@en .

<https://www.glossarist.org/ontologies/completeness/partial> a skos:Concept ;
  skos:inScheme gloss:completeness ;
  skos:prefLabel "partial"@en ;
  skos:definition "The encoded partitives are some of the partitives of the comprehensive; others exist but are not encoded."@en .

gloss:completeness skos:hasTopConcept
    <https://www.glossarist.org/ontologies/completeness/complete> ,
    <https://www.glossarist.org/ontologies/completeness/partial> .
```

### member-certainty.ttl (new)

```turtle
# Member Certainty Taxonomy
#
# SKOS ConceptScheme for the certainty of a partitive member within
# a PartitiveRelation. Glossarist extension beyond ISO notation,
# which only supports set-level plurality uncertainty.
#
# Two values: confirmed (default; definitely a member) and possible
# (might be a member).

@prefix gloss:   <https://www.glossarist.org/ontologies/> .
@prefix skos:    <http://www.w3.org/2004/02/skos/core#> .
@prefix dcterms: <http://purl.org/dc/terms/> .

gloss:memberCertainty a skos:ConceptScheme ;
  skos:prefLabel "Member Certainty"@en ;
  skos:definition "Per-partitive certainty within a PartitiveRelation. Glossarist extension beyond ISO 704 notation."@en ;
  dcterms:source <https://www.glossarist.org/schemas/v3/concept> .

<https://www.glossarist.org/ontologies/memberCertainty/confirmed> a skos:Concept ;
  skos:inScheme gloss:memberCertainty ;
  skos:prefLabel "confirmed"@en ;
  skos:definition "This partitive is definitely a member of the decomposition."@en .

<https://www.glossarist.org/ontologies/memberCertainty/possible> a skos:Concept ;
  skos:inScheme gloss:memberCertainty ;
  skos:prefLabel "possible"@en ;
  skos:definition "This partitive may or may not be a member of the decomposition. Used when sources disagree or identification is provisional."@en .

gloss:memberCertainty skos:hasTopConcept
    <https://www.glossarist.org/ontologies/memberCertainty/confirmed> ,
    <https://www.glossarist.org/ontologies/memberCertainty/possible> .
```

### concept-status.ttl (updated)

Add the `external` concept:

```turtle
<https://www.glossarist.org/ontologies/status/external> a skos:Concept ;
  skos:inScheme gloss:status ;
  skos:prefLabel "external"@en ;
  skos:definition "A concept referenced from this dataset but defined elsewhere. Resolves via RelatedConceptType#provided_by when a defining dataset is loaded."@en .

gloss:status skos:hasTopConcept
    <https://www.glossarist.org/ontologies/status/draft> ,
    <https://www.glossarist.org/ontologies/status/valid> ,
    <https://www.glossarist.org/ontologies/status/retired> ,
    <https://www.glossarist.org/ontologies/status/external> .
```

### relationship-type.ttl (updated)

Add `provides` and `provided_by`:

```turtle
<https://www.glossarist.org/ontologies/rel/provides> a skos:Concept ;
  skos:inScheme gloss:rel ;
  skos:prefLabel "provides"@en ;
  skos:definition "The current concept provides the substance for an external concept. Established at the collection level."@en .

<https://www.glossarist.org/ontologies/rel/provided_by> a skos:Concept ;
  skos:inScheme gloss:rel ;
  skos:prefLabel "provided by"@en ;
  skos:definition "The current external concept is provided by another concept (its real definition)."@en .

# Inverse relationship
<https://www.glossarist.org/ontologies/rel/provides>
  owl:inverseOf <https://www.glossarist.org/ontologies/rel/provided_by> .
```

### Deletions

```
# DELETE: ontologies/taxonomies/partitive-enumeration.ttl
#   (replaced by completeness.ttl)
# DELETE: ontologies/taxonomies/plurality-marker.ttl
#   (replaced by TypeSharedPlurality class — no enum equivalent)
```

## Verification

```bash
# All taxonomies parse
bundle exec exe/validate-ontologies

# New taxonomies exist
test -f ontologies/taxonomies/completeness.ttl
test -f ontologies/taxonomies/member-certainty.ttl

# Deleted taxonomies gone
test ! -f ontologies/taxonomies/partitive-enumeration.ttl
test ! -f ontologies/taxonomies/plurality-marker.ttl

# Enum drift still passes
bundle exec exe/check-enum-drift
```

## Status: pending
