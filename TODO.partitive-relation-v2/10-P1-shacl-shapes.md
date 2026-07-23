# 10 — P1: SHACL shapes for the v2 model

## Problem

The v2 model adds three new classes (PartitiveMember,
TypeSharedPlurality) and renames several (PartitiveHyperedge →
PartitiveRelation; hasPart → hasPartitive; etc.). SHACL shapes must
follow.

This document consolidates all SHACL shape changes. Per-class
changes are also described in items 01–07; this is the integrated
view.

## Scope

- `ontologies/shapes/glossarist.shacl.ttl` — full rewrite of the
  PartitiveHyperedge section as PartitiveRelation + PartitiveMember +
  TypeSharedPlurality

## Concrete shapes

### PartitiveRelation

```turtle
gloss:PartitiveRelationShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveRelation ;
  sh:property [
    sh:path gloss:comprehensive ;
    sh:class gloss:ConceptRef ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:hasPartitive ;
    sh:class gloss:PartitiveMember ;
    sh:minCount 2 ;                          # ISO: "two or more"
  ] ;
  sh:property [
    sh:path gloss:completeness ;
    sh:class skos:Concept ;
    sh:valuesFrom <https://www.glossarist.org/ontologies/completeness> ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:hasPlurality ;
    sh:class gloss:TypeSharedPlurality ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:criterion ;
    sh:datatype rdf:langString ;
  ] .

# Ownership invariant (soft warning) — preserved from v1
gloss:PartitiveRelationOwnershipShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveRelation ;
  sh:severity sh:Warning ;
  sh:message "partitive_relation is carried by a concept that is not its comprehensive — confirm the cross-reference is intentional."@en ;
  sh:sparql [
    a sh:SPARQLConstraint ;
    sh:prefixes [
      sh:declare [ sh:prefix "gloss" ; sh:namespace "https://www.glossarist.org/ontologies/"^^xsd:anyURI ] ;
      sh:declare [ sh:prefix "xsd" ; sh:namespace "http://www.w3.org/2001/XMLSchema#"^^xsd:anyURI ] ;
    ] ;
    sh:select """
      SELECT $this ?carryingConcept ?compRef
      WHERE {
        ?carryingConcept gloss:hasPartitiveRelation $this .
        $this gloss:comprehensive ?compRef .
        OPTIONAL { ?compRef gloss:conceptRefId ?literalId . }
        BIND(COALESCE(?literalId, STRAFTER(STR(?compRef), CONCAT(STR(?carryingConcept), "/"))) AS ?compKey)
        FILTER (BOUND(?compKey) && !STRENDS(STR(?carryingConcept), CONCAT("/", ?compKey)))
      }
    """ ;
  ] .
```

### PartitiveMember

```turtle
gloss:PartitiveMemberShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveMember ;
  sh:property [
    sh:path gloss:ref ;
    sh:class gloss:ConceptRef ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:certainty ;
    sh:class skos:Concept ;
    sh:valuesFrom <https://www.glossarist.org/ontologies/memberCertainty> ;
    sh:maxCount 1 ;
  ] .
```

### TypeSharedPlurality

```turtle
gloss:TypeSharedPluralityShape a sh:NodeShape ;
  sh:targetClass gloss:TypeSharedPlurality ;
  sh:property [
    sh:path gloss:isShared ;
    sh:datatype xsd:boolean ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:isUncertain ;
    sh:datatype xsd:boolean ;
    sh:maxCount 1 ;
  ] ;
  sh:property [
    sh:path gloss:sharedType ;
    sh:class gloss:ConceptRef ;
    sh:maxCount 1 ;
  ] .
```

### ExternalConcept (no new shape)

ExternalConcept is a ManagedConcept with `status: external`. The
existing `gloss:ConceptShape` applies. The only addition is a
**coherence rule**:

```turtle
# ExternalConcept must not have a definition (it's undefined by design)
gloss:ExternalConceptCoherenceShape a sh:NodeShape ;
  sh:targetSubjectsOf gloss:hasStatus ;        # any concept with a status
  sh:sparql [
    a sh:SPARQLConstraint ;
    sh:prefixes [
      sh:declare [ sh:prefix "gloss" ; sh:namespace "https://www.glossarist.org/ontologies/"^^xsd:anyURI ] ;
    ] ;
    sh:select """
      SELECT $this ?definition
      WHERE {
        $this gloss:hasStatus <https://www.glossarist.org/ontologies/status/external> .
        $this gloss:hasDefinition ?definition .
      }
    """ ;
    sh:message "An external concept must not have a definition — that's the point of status: external."@en ;
  ] .
```

### ConceptShape (updated)

```turtle
gloss:ConceptShape a sh:NodeShape ;
  sh:targetClass gloss:Concept ;
  # ... existing properties ...
  sh:property [
    sh:path gloss:hasPartitiveRelation ;       # was: gloss:hasPartitiveHyperedge
    sh:class gloss:PartitiveRelation ;
  ] ;
  # ... rest unchanged ...
.
```

## Verification

```bash
bundle exec exe/validate-ontologies
bundle exec exe/check-shacl-coverage
```

Both should pass after this change.

## Status: pending
