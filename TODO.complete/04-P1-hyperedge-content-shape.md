# 04 — P1: Add SHACL `gloss:hyperedgeContent` property shape

## Problem

The contributor's `TODO.hyperedges/29-P1-concept-model-hyperedge-content-property.md`
added the `gloss:hyperedgeContent` ontology property and stated:

> The SHACL shape file references this property path for the
> `content` field on `gloss:PartitiveHyperedge`.

Status was claimed "✅ Done." **It isn't.** The SHACL file has no
property shape for `gloss:hyperedgeContent`. `gloss:RelatedConceptShape`
DOES shape `gloss:relationshipContent` (the analog), so the new
property is asymmetric with the existing pattern.

## Fix

Add to `gloss:PartitiveHyperedgeShape` in
`ontologies/shapes/glossarist.shacl.ttl`:

```ttl
  sh:property [
    sh:path gloss:hyperedgeContent ;
    sh:datatype xsd:string ;
    sh:maxCount 1 ;
  ] ;
```

## Verification

```bash
grep -A3 "gloss:hyperedgeContent" ontologies/shapes/glossarist.shacl.ttl
```

## Status: pending
