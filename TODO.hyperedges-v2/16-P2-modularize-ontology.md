# 16 — P2: Modularize `ontologies/glossarist.ttl`

## Problem

`ontologies/glossarist.ttl` is 1412 lines. It contains classes
and properties for: concepts, designations, sources/citations,
dates, non-verbal representations, relationships, sections,
datasets, and now hyperedges — all in one file.

Navigation is hard. Merge conflicts are frequent. Domain-specific
changes touch a giant file.

## Fix

Split by domain:

```
ontologies/
  glossarist.ttl                    ← prefixes + imports (becomes ~50 lines)
  classes/
    concept.ttl
    localized_concept.ttl
    designation.ttl
    detailed_definition.ttl
    concept_source.ttl
    concept_date.ttl
    non_verbal_entity.ttl
    related_concept.ttl
    partitive_hyperedge.ttl
    concept_collection.ttl
    dataset_register.ttl
    section.ttl
    reference.ttl
  properties/
    concept_properties.ttl
    designation_properties.ttl
    source_properties.ttl
    date_properties.ttl
    relationship_properties.ttl
    hyperedge_properties.ttl
    ...
```

The top-level `glossarist.ttl` becomes a manifest:

```turtle
@prefix gloss: <https://www.glossarist.org/ontologies/> .
@prefix owl:   <http://www.w3.org/2002/07/owl#> .

gloss:Ontology a owl:Ontology ;
  owl:imports gloss:classes/concept.ttl ,
              gloss:classes/localized_concept.ttl ,
              ...
              gloss:properties/concept_properties.ttl ,
              ... .
```

## Verification

`scripts/validate-ontologies.py` should still pass on every file.
The merged-graph check (item 11 in TODO.complete) ensures
cross-file references resolve.

## Risk

Large diff. Existing PRs that touch `glossarist.ttl` will conflict.
Mitigation: do this in a quiet period.

## Out of scope for this PR

Plan only. Execute in a dedicated PR.

## Status: pending (P2 — large refactor)
