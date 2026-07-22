# 02 — P0: Add SHACL shapes for 5 unshaped classes

## Problem

Cross-checking the ontology against the SHACL file finds 5
`owl:Class` declarations with no `sh:NodeShape`:

- `gloss:PartitiveEnumeration` — declared as `owl:Class` but it's
  really a SKOS scheme container; the *concepts* in the scheme
  already have `skos:Concept` shape via SHACL `sh:valuesFrom`.
  A `sh:NodeShape` declaring `sh:class skos:ConceptScheme` makes
  the class-to-scheme link explicit.
- `gloss:PluralityMarker` — same pattern.
- `gloss:FigureImage` — non-verbal entity subtype; needs shape for
  its specific properties (`src`, `format`, etc.).
- `gloss:NonVerbalEntity` — abstract base; needs shape for shared
  properties.
- `gloss:SharedNonVerbalEntity` — shared dataset-wide entity;
  needs shape for shared properties.

The blank-node IDs (`n598062e7a99440ac837187c65708df8ab*`) from
`owl:unionOf` constructions are expected; not real classes.

## Fix

Add to `ontologies/shapes/glossarist.shacl.ttl`:

```ttl
gloss:PartitiveEnumerationShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveEnumeration ;
  sh:class skos:ConceptScheme .

gloss:PluralityMarkerShape a sh:NodeShape ;
  sh:targetClass gloss:PluralityMarker ;
  sh:class skos:ConceptScheme .

gloss:NonVerbalEntityShape a sh:NodeShape ;
  sh:targetClass gloss:NonVerbalEntity ;
  sh:property [
    sh:path gloss:altText ;
    sh:datatype xsd:string ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:description ;
    sh:datatype xsd:string ;
  ] .

gloss:SharedNonVerbalEntityShape a sh:NodeShape ;
  sh:targetClass gloss:SharedNonVerbalEntity ;
  sh:class gloss:NonVerbalEntity .

gloss:FigureImageShape a sh:NodeShape ;
  sh:targetClass gloss:FigureImage ;
  sh:property [
    sh:path gloss:src ;
    sh:datatype xsd:string ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:format ;
    sh:datatype xsd:string ;
    sh:maxCount 1 ;
  ] .
```

Verify property paths against `ontologies/glossarist.ttl` before
landing — some may already be shaped at a parent level.

## Verification

The new `scripts/check-shacl-coverage.py` (item 06) reports 0
unshaped classes.

```bash
python scripts/check-shacl-coverage.py
```

## Status: pending
