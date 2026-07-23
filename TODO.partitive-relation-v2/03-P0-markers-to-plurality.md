# 03 — P0: markers → plurality (data not notation); add shared_type

## Problem

The shipped `markers: [double, dashed]` field encoded diagram
notation flags. Per ISO 704:

- **close-set double line** = "several partitive concepts **of a
  given type** are involved" — a type-shared plurality claim
- **broken line** = "such plurality is uncertain" — qualifies the
  plurality claim

These are **semantic claims about the relation**, not just rendering
hints. Encoding them as opaque marker strings meant:

1. The data was opaque — `markers: [double]` doesn't say *what type*
   the partitives share
2. Tools couldn't reason about the claims — they could only
   reproduce the diagram
3. The semantic content was duplicated in human interpretation

This change promotes the markers to data. The diagram-notation form
is dropped — rendering is computed from data when needed.

## Scope

- `models/concepts/PluralityMarker.lutaml` → DELETE (replaced by
  `TypeSharedPlurality` class)
- `models/concepts/TypeSharedPlurality.lutaml` → NEW
- `schemas/v3/concept.yaml` — replace `markers` property with
  `plurality`
- `ontologies/taxonomies/plurality-marker.ttl` → DELETE
- `ontologies/glossarist.ttl` — replace `gloss:hasPluralityMarker`
  with structured properties

## Concrete changes

### New LUTAML class

```ruby
# models/concepts/TypeSharedPlurality.lutaml
class TypeSharedPlurality {
  definition {
    Semantic claims encoded by ISO 704's close-set double line
    and broken line notation. Promoted from rendering flags to
    data so tools can reason about plurality directly.

    A PartitiveRelation has at most one TypeSharedPlurality block.
    Absent means: no type-shared plurality claim is being made.
  }
  +is_shared: Boolean [1..1] {
    definition {
      ISO 704 close-set double line. True when several partitives
      of a given type are involved in the relation.

      Distinct from cardinality alone: three partitives of
      different types do not satisfy this; three partitives of
      the same type do.
    }
  }
  +is_uncertain: Boolean [0..1] {
    definition {
      ISO 704 broken line. True when the type-shared plurality
      is uncertain — the relation asserts the plurality exists
      but its boundaries (how many partitives, which ones) are
      not firmly established.

      Defaults to false when omitted.
    }
  }
  +shared_type: <<StandardDocument>> ReferenceToTermbase [0..1] {
    definition {
      Glossarist extension. The type the partitives share, when
      known. ISO notation does not encode this; it is left for
      the reader to infer.

      Optional even when is_shared is true — we may know the
      partitives share a type without knowing which.
    }
  }
}
```

### PartitiveRelation change

```ruby
class PartitiveRelation {
  # ...
  +plurality: TypeSharedPlurality [0..1] {
    definition {
      Optional block carrying the type-shared plurality claim
      for this relation. Absent means no such claim is made.

      Replaces the prior `markers` field, which encoded the same
      information as opaque diagram-notation strings.
    }
  }
  # DELETE: +markers: PluralityMarker [0..*]
}
```

### Schema

```yaml
# schemas/v3/concept.yaml
$defs:
  # DELETE: plurality_marker

  type_shared_plurality:
    type: object
    description: |
      Type-shared plurality claim encoded by ISO 704's
      close-set double line and broken line notation.

      Promoted from diagram-notation markers to structured data
      so tools can reason about plurality without reproducing
      the source diagram's visual style.
    properties:
      is_shared:
        type: boolean
        description: |
          ISO 704 close-set double line. True when several
          partitives of a given type are involved.
      is_uncertain:
        type: boolean
        default: false
        description: |
          ISO 704 broken line. True when the type-shared
          plurality is uncertain.
      shared_type:
        $ref: "#/$defs/concept_ref"
        description: |
          Glossarist extension. The type the partitives share,
          when known. ISO notation does not encode this.
    required:
      - is_shared
    additionalProperties: false

  partitive_relation:
    # ...
    properties:
      # ...
      plurality:                                # was: markers
        $ref: "#/$defs/type_shared_plurality"
      # DELETE: markers
```

### Ontology

```turtle
# ontologies/glossarist.ttl
gloss:TypeSharedPlurality a owl:Class ;
  rdfs:label "Type-Shared Plurality"@en ;
  rdfs:comment """
    Semantic claims encoded by ISO 704's close-set double line and
    broken line notation. Promoted from rendering flags to data.
  """@en .

gloss:hasPlurality a owl:ObjectProperty ;
  rdfs:domain gloss:PartitiveRelation ;
  rdfs:range gloss:TypeSharedPlurality ;
  rdfs:label "has plurality"@en ;
  rdfs:comment "Optional type-shared plurality block on a partitive relation."@en .

gloss:isShared a owl:DatatypeProperty ;
  rdfs:domain gloss:TypeSharedPlurality ;
  rdfs:range xsd:boolean ;
  rdfs:label "is shared"@en ;
  rdfs:comment "ISO 704 close-set double line. True when several partitives of a given type are involved."@en .

gloss:isUncertain a owl:DatatypeProperty ;
  rdfs:domain gloss:TypeSharedPlurality ;
  rdfs:range xsd:boolean ;
  rdfs:label "is uncertain"@en ;
  rdfs:comment "ISO 704 broken line. True when the type-shared plurality is uncertain."@en .

# gloss:sharedType reuses gloss:comprehensive-like range; or define as object property pointing at ConceptRef
gloss:sharedType a owl:ObjectProperty ;
  rdfs:domain gloss:TypeSharedPlurality ;
  rdfs:range gloss:ConceptRef ;
  rdfs:label "shared type"@en ;
  rdfs:comment "Glossarist extension. The type the partitives share, when known."@en .

# DELETE:
# gloss:PluralityMarker a owl:Class
# gloss:hasPluralityMarker a owl:ObjectProperty
```

### SHACL

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

gloss:PartitiveRelationShape a sh:NodeShape ;
  sh:targetClass gloss:PartitiveRelation ;
  # ...
  sh:property [
    sh:path gloss:hasPlurality ;
    sh:class gloss:TypeSharedPlurality ;
    sh:maxCount 1 ;
  ] ;
  # DELETE: sh:property block for gloss:hasPluralityMarker
.
```

### JSON-LD context

```jsonld
"TypeSharedPlurality": "gloss:TypeSharedPlurality",
"hasPlurality":        { "@id": "gloss:hasPlurality", "@type": "@id" },
"isShared":            { "@id": "gloss:isShared", "@type": "xsd:boolean" },
"isUncertain":         { "@id": "gloss:isUncertain", "@type": "xsd:boolean" },
"sharedType":          { "@id": "gloss:sharedType", "@type": "@id" },
// DELETE: PluralityMarker, hasPluralityMarker
```

### Taxonomy

```
# DELETE: ontologies/taxonomies/plurality-marker.ttl
# (no replacement — TypeSharedPlurality is a class, not an enum)
```

## Verification

```bash
! grep -r "PluralityMarker\|plurality_marker\|hasPluralityMarker" \
    models/ schemas/ ontologies/ docs/
test ! -f ontologies/taxonomies/plurality-marker.ttl

make validate
```

## Migration

Old markers map to new plurality:

| Old markers | New plurality |
|-------------|---------------|
| `[]` or omitted | omitted |
| `[double]` | `{is_shared: true}` |
| `[dashed]` | (drop, or set is_uncertain: true with is_shared: false — semantically odd) |
| `[double, dashed]` | `{is_shared: true, is_uncertain: true}` |

The `[dashed]` alone case is semantically odd (broken line qualifies
the double-line plurality claim; without `double`, what is the
plurality being qualified?). Migration sets `is_shared: false,
is_uncertain: true` and flags for human review.

`shared_type` is never set by migration (ISO notation doesn't encode
the type). Reviewers fill it in during dataset review where known.

See `08-P1-migration-script.md`.

## Status: pending
