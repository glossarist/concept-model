# 02 — P0: enumeration → completeness

## Problem

The shipped field `enumeration` with values `closed|open` was a
neutral-sounding name that didn't convey the semantic. ISO 704's
description is about the **backline of the rake**: a backline that
ends with a tooth (closed — these are all the parts) vs a backline
that continues without a tooth (open — more parts exist).

The data claim being expressed is **completeness of the
decomposition**. The name should reflect that.

## Scope

- `models/concepts/PartitiveEnumeration.lutaml` → rename to `Completeness.lutaml`
- `schemas/v3/concept.yaml` $def rename: `partitive_enumeration` → `completeness`
- `ontologies/taxonomies/partitive-enumeration.ttl` → rename to `completeness.ttl`
- SHACL, JSON-LD context updates

## Concrete changes

### LUTAML model

```ruby
# models/concepts/Completeness.lutaml (renamed from PartitiveEnumeration.lutaml)
enum Completeness {
  definition {
    Whether the encoded partitives fitted together constitute the
    whole comprehensive concept (complete) or only some of it
    (partial — other partitives exist that are not encoded).

    ISO 704 depicts this as the rake's backline: a backline ending
    with a tooth is complete; a backline continuing without a tooth
    is partial.
  }

  complete {
    definition {
      The encoded partitives fitted together constitute the
      comprehensive concept. No further partitives exist. Adding
      or removing a partitive would change the relationship.

      ISO 704 depicts this as a rake whose backline ends with a
      tooth.
    }
  }

  partial {
    definition {
      The encoded partitives are some of the partitives of the
      comprehensive; others exist but are not encoded here. The
      relationship asserts only that the comprehensive has at
      least these parts.

      ISO 704 depicts this as a rake whose backline continues
      without a tooth.
    }
  }
}
```

### Schema

```yaml
# schemas/v3/concept.yaml
$defs:
  completeness:                              # was: partitive_enumeration
    type: string
    description: |
      Whether the encoded partitives fitted together constitute
      the whole comprehensive concept (complete) or only some of
      it (partial).
    enum:
      - complete                              # was: closed
      - partial                               # was: open

  partitive_relation:
    properties:
      # ...
      completeness:                           # was: enumeration
        $ref: "#/$defs/completeness"
        default: complete
        description: |
          Completeness of the parts list. `complete` (default)
          asserts that the encoded partitives fitted together
          constitute the comprehensive. `partial` asserts that
          other partitives exist beyond those encoded.
```

### Taxonomy

```turtle
# ontologies/taxonomies/completeness.ttl (renamed from partitive-enumeration.ttl)
@prefix gloss:   <https://www.glossarist.org/ontologies/> .
@prefix skos:    <http://www.w3.org/2004/02/skos/core#> .
@prefix dcterms: <http://purl.org/dc/terms/> .

gloss:completeness a skos:ConceptScheme ;       # was: gloss:partitiveEnumeration
  skos:prefLabel "Completeness"@en ;
  skos:definition "Whether the encoded partitives constitute the whole comprehensive (complete) or only some of it (partial)."@en ;
  dcterms:source <https://www.glossarist.org/schemas/v3/concept> .

<https://www.glossarist.org/ontologies/completeness/complete> a skos:Concept ;
  skos:inScheme gloss:completeness ;
  skos:prefLabel "complete"@en ;
  skos:definition "The encoded partitives fitted together constitute the comprehensive concept."@en .

<https://www.glossarist.org/ontologies/completeness/partial> a skos:Concept ;
  skos:inScheme gloss:completeness ;
  skos:prefLabel "partial"@en ;
  skos:definition "The encoded partitives are some of the partitives of the comprehensive; others exist."@en .

gloss:completeness skos:hasTopConcept
    <https://www.glossarist.org/ontologies/completeness/complete> ,
    <https://www.glossarist.org/ontologies/completeness/partial> .
```

### SHACL

```turtle
# ontologies/shapes/glossarist.shacl.ttl
gloss:PartitiveRelationShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveRelation ;
  # ...
  sh:property [
    sh:path gloss:completeness ;              # was: gloss:enumeration
    sh:class skos:Concept ;
    sh:valuesFrom <https://www.glossarist.org/ontologies/completeness> ;
    sh:maxCount 1 ;
  ] ;
  # ...
.
```

### JSON-LD context

```jsonld
"completeness": { "@id": "gloss:completeness", "@type": "@id" },   // was: enumeration
```

## Verification

```bash
! grep -r "partitive_enumeration\|PartitiveEnumeration\|enumeration:" \
    models/ schemas/ ontologies/ docs/
! grep -E "enumeration: (closed|open)" schemas/v3/examples/

make validate
```

## Migration

Old `enumeration: closed` → new `completeness: complete`.
Old `enumeration: open` → new `completeness: partial`.
Old `enumeration` omitted → new `completeness` omitted (defaults to `complete`).

See `08-P1-migration-script.md`.

## Status: pending
