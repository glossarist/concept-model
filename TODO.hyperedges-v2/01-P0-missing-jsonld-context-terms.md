# 01 — P0: Add missing JSON-LD context terms

## Problem

Cross-checking the ontology against `ontologies/glossarist.context.jsonld`
finds 4 `owl:ObjectProperty` / `owl:DatatypeProperty` declarations
with no JSON-LD context entry:

- `gloss:relatedConceptBroader`
- `gloss:relatedConceptNarrower`
- `gloss:source` (the property; the *prefix* `source` already maps to a context term — `conceptRefSource` etc.)
- `gloss:tag`

RDF consumers reading YAML as JSON-LD silently drop these.

## Fix

Add to `ontologies/glossarist.context.jsonld`:

```jsonld
"relatedConceptBroader": { "@id": "gloss:relatedConceptBroader", "@type": "@id" },
"relatedConceptNarrower": { "@id": "gloss:relatedConceptNarrower", "@type": "@id" },
"source":                { "@id": "gloss:source", "@type": "xsd:string" },
"tag":                   { "@id": "gloss:tag", "@type": "xsd:string" },
```

Place near the related-concept / source / tag blocks (lines ~112, ~123, ~70).

## Verification

The new `scripts/check-jsonld-context.py` (item 05) reports 0 missing.

```bash
python scripts/check-jsonld-context.py
```

## Status: pending
