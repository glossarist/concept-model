# 05 — P1: Update JSON-LD context with hyperedge terms

## Problem

`ontologies/glossarist.context.jsonld` has `relationshipContent` (line
113) but no entries for any of the new PartitiveHyperedge terms.
RDF consumers reading YAML as JSON-LD will silently drop these fields.

Missing terms (all declared in `ontologies/glossarist.ttl`):

- `hasPartitiveHyperedge` (ObjectProperty, range PartitiveHyperedge)
- `comprehensive` (ObjectProperty, range ConceptRef)
- `hasPart` (ObjectProperty, range ConceptRef)
- `enumeration` (ObjectProperty, range PartitiveEnumeration)
- `hasPluralityMarker` (ObjectProperty, range PluralityMarker)
- `hyperedgeContent` (DatatypeProperty, range xsd:string)

Also missing the class term:
- `PartitiveHyperedge` (owl:Class)
- `PartitiveEnumeration` (owl:Class)
- `PluralityMarker` (owl:Class)

## Fix

Add to `ontologies/glossarist.context.jsonld`:

```jsonld
"PartitiveHyperedge":   "gloss:PartitiveHyperedge",
"PartitiveEnumeration": "gloss:PartitiveEnumeration",
"PluralityMarker":      "gloss:PluralityMarker",

"hasPartitiveHyperedge": { "@id": "gloss:hasPartitiveHyperedge", "@type": "@id" },
"comprehensive":         { "@id": "gloss:comprehensive",         "@type": "@id" },
"hasPart":               { "@id": "gloss:hasPart",               "@type": "@id" },
"enumeration":           { "@id": "gloss:enumeration",           "@type": "@id" },
"hasPluralityMarker":    { "@id": "gloss:hasPluralityMarker",    "@type": "@id" },
"hyperedgeContent":      { "@id": "gloss:hyperedgeContent",      "@type": "xsd:string" },
```

Place class terms near the other class declarations (lines 17-49) and
property terms near the existing `relationshipContent` block (line 113).

## Verification

A round-trip test: render example 20 as JSON-LD using this context,
parse with rdflib, confirm `gloss:comprehensive` and `gloss:hasPart`
triples appear.

## Status: pending
