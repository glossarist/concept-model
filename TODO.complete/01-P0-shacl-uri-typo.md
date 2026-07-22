# 01 — P0: Fix SHACL `sh:valuesFrom` URI typos

## Problem

`ontologies/shapes/glossarist.shacl.ttl:744` and `:750` reference
kebab-case URIs that don't exist:

```ttl
sh:valuesFrom <https://www.glossarist.org/ontologies/partitive-enumeration> ;
sh:valuesFrom <https://www.glossarist.org/ontologies/plurality-marker> ;
```

The actual `skos:ConceptScheme` URIs declared in the taxonomy files are
camelCase:

```
ontologies/taxonomies/partitive-enumeration.ttl:11
  gloss:partitiveEnumeration a skos:ConceptScheme ;

ontologies/taxonomies/plurality-marker.ttl:12
  gloss:pluralityMarker a skos:ConceptScheme ;
```

Result: the value-range constraint is silently a no-op. Any
`skos:Concept` passes because the scheme lookup fails.

## Why this happened

The contributor's own plan (`glossarist-ruby/TODO.hyperedges/27-P0-concept-model-shacl-skos.md`)
spec'd the kebab-case URIs. The plan was wrong from the start; nobody
cross-checked against the taxonomy files. The "✅ Done" claim was based
on the spec, not the state.

## Fix

In `ontologies/shapes/glossarist.shacl.ttl`:

```
partitive-enumeration  →  partitiveEnumeration
plurality-marker       →  pluralityMarker
```

## Verification

```python
from rdflib import Graph, Namespace, RDF
from rdflib.namespace import SKOS

tax = Graph()
for f in Path("ontologies/taxonomies").glob("*.ttl"):
    tax.parse(f)
shacl = Graph(); shacl.parse("ontologies/shapes/glossarist.shacl.ttl")

SHACL = Namespace("http://www.w3.org/ns/shacl#")
tax_schemes = set(map(str, tax.subjects(RDF.type, SKOS.ConceptScheme)))
shacl_targets = set(map(str, shacl.objects(None, SHACL.valuesFrom)))

broken = shacl_targets - tax_schemes
assert not broken, f"SHACL sh:valuesFrom URIs not in any taxonomy: {broken}"
```

## Status: pending
