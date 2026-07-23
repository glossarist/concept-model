# 11 — P1: JSON-LD context updates

## Problem

The v2 model renames classes and properties. JSON-LD context
entries must follow. New classes (PartitiveMember,
TypeSharedPlurality) need entries. Removed fields (hyperedgeContent,
markers) need their entries deleted.

## Scope

- `ontologies/glossarist.context.jsonld` — update for v2

## Concrete changes

### Additions

```jsonld
"PartitiveRelation":      "gloss:PartitiveRelation",
"PartitiveMember":        "gloss:PartitiveMember",
"TypeSharedPlurality":    "gloss:TypeSharedPlurality",

"hasPartitiveRelation":   { "@id": "gloss:hasPartitiveRelation", "@type": "@id" },
"hasPartitive":           { "@id": "gloss:hasPartitive", "@type": "@id" },
"hasPlurality":           { "@id": "gloss:hasPlurality", "@type": "@id" },
"isShared":               { "@id": "gloss:isShared", "@type": "xsd:boolean" },
"isUncertain":            { "@id": "gloss:isUncertain", "@type": "xsd:boolean" },
"sharedType":             { "@id": "gloss:sharedType", "@type": "@id" },

"criterion":              { "@id": "gloss:criterion", "@container": "@language" },

"provides":               { "@id": "gloss:provides", "@type": "@id" },
"provided_by":            { "@id": "gloss:providedBy", "@type": "@id" },
```

### Deletions

```jsonld
// DELETE — renamed/replaced in v2:
"PartitiveHyperedge":       "gloss:PartitiveHyperedge",
"PartitiveEnumeration":     "gloss:PartitiveEnumeration",
"PluralityMarker":          "gloss:PluralityMarker",
"hasPartitiveHyperedge":    { ... },
"hasPluralityMarker":       { ... },
"enumeration":              { ... },
"hyperedgeContent":         { ... },
```

### Unchanged

```jsonld
"comprehensive":            { "@id": "gloss:comprehensive", "@type": "@id" },
// (the field name 'comprehensive' is the same in v1 and v2;
//  only the containing class changed)
```

## JSON-LD container semantics

`criterion` uses `@container: @language` so a YAML hash like
`{ eng: "physical structure", fra: "structure physique" }` expands
to multiple language-tagged literals in RDF:

```turtle
<relation-x> gloss:criterion "physical structure"@en ,
                            "structure physique"@fr .
```

This matches the `sh:datatype rdf:langString` SHACL constraint
from item 10.

## Verification

```bash
# Context parses as JSON
python3 -c "import json; json.load(open('ontologies/glossarist.context.jsonld'))"

# All ontology properties have context entries
bundle exec exe/check-jsonld-context

# No leftover v1 terms
! grep -E "PartitiveHyperedge|PartitiveEnumeration|PluralityMarker|hyperedgeContent" \
    ontologies/glossarist.context.jsonld
```

## Downstream impact

- glossarist-ruby: RDF emission uses new terms; JSON-LD expansion
  uses new context
- glossarist-js: JSON-LD parser updates automatically when
  consumers point at the new context URL
- concept-browser: data pipeline uses new context for JSON-LD
  serialization

See `17-downstream-consumer-guide.md`.

## Status: pending
