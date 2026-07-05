# Release Notes

Per-release notes for the Glossarist concept-model. Each entry summarizes
ontology, schema, and shape changes with consumer impact.

Consumers that vendor concept-model artifacts (glossarist-ruby,
glossarist-js, concept-browser) should consult these notes when bumping
their pinned tag.

---

## v3.1.0 — 2026-07-05

Additive release: new classes, properties, shapes, and examples. No
existing URI was removed or renamed. The prefix spelling change
(`xl:` → `skosxl:`) preserves the same IRI binding.

### New ontology classes

- `gloss:DatasetRegister` — self-describing dataset metadata (register.yaml)
- `gloss:Section` — structural division within a dataset (hierarchical)
- `gloss:NonVerbalEntity` — abstract base for non-verbal representations
- `gloss:SharedNonVerbalEntity` — dataset-wide identity (parent of Figure/Table/Formula)
- `gloss:Figure`, `gloss:Table`, `gloss:Formula` — dataset-level NVR entities
- `gloss:FigureImage` — image variant within a Figure
- `gloss:DesignationRelationship` — designation-level relationship (ISO 10241-1 §5.4.2)

### New SHACL shapes

- `DatasetRegisterShape`, `SectionShape`
- `FigureShape`, `TableShape`, `FormulaShape`
- `ImageShape` (targets `foaf:Image`)
- `NonVerbalRepresentationShape` (concept-level NVR)

### New properties

- Dataset register: `datasetId`, `datasetUrn`, `datasetStatus`, `hasSection`,
  `hasDefaultOrdering`, `owner`, `sourceRepo`, `languageOrder`, etc.
- Section: `sectionId`, `sectionName`, `hasChildSection` (transitive),
  `hasParentSection` (transitive inverse), `sectionOrdering`
- Non-verbal: `caption`, `altText`, `description`, `expression`, `latexForm`,
  `content`, `hasSubfigure`, `src`, `format`, `role`
- Concept source: `sourceId` (for `{{cite:id}}` inline mentions)
- Scoped examples: `hasScopedExample` (MECE with concept-level `hasExample`)
- Designation: `hasDesignationRelationship`, `designationRelationshipType`,
  `designationRelationshipContent`, `relationshipTarget`

### New SKOS taxonomies

- `ontologies/taxonomies/ordering-method.ttl` — systematic, mixed, alphabetical
- `ontologies/taxonomies/concept-reference-type.ttl` — domain, section, local, designation

### Canonical prefixes

- `ontologies/prefixes.ttl` — single source of truth for prefix bindings
- `skosxl:` is the canonical SKOS-XL prefix (was `xl:` in v3.0.0)

### Consumer impact

| Consumer | Action needed |
|---|---|
| glossarist-ruby | Re-sync vendored data: `rake glossarist:sync:model[v3.1.0]` |
| glossarist-js | Re-sync vendored data to v3.1.0 |
| concept-browser | Update vendored shapes; prefix `xl:` → `skosxl:` in any local declarations |

### Known follow-ups

- Emitter-level fixes in glossarist-ruby for full SHACL conformance
  (see glossarist-ruby PR #188 Phase 2)
