# GenericRelation Design

## Status

Proposed — 2026-07-29. Implementation: TODO.general-rels.

## ISO 704 reference

ISO 704:2022 §5.5.4.1 describes generic concept-system relations
(genus–species hierarchies) with the same diagram-notation conventions
as partitive relations: close-set double line, broken line, delimiting
part, completeness.

## Evidence of need

OIML V 2-200:2010 (International Vocabulary of Terms in Legal Metrology)
contains ~8 generic hyperedges (n-ary rake decompositions), several with
multiple criterion-of-subdivision groups:

- **5.1 measurement standard** has 6 groups: by realization medium,
  by calibration role, by governance level, by metrological hierarchy,
  by reference/working role, by travel role
- **5.13 reference material** has 2 groups: by certification, by purpose
- **"(precision condition of measurement)"** (ExternalConcept comprehensive)
  has 2 groups: by participant type, by precision type

See `memory/reference_oiml_v2_200_generic_hyperedges.md` for the full
inventory (archived in agent memory).

Binary `broader_generic` / `narrower_generic` edges cannot express
"these 4 species are coordinate concepts sharing comprehensive X and
criterion Y" as a joint claim. They can only assert pairwise hierarchy.

## Design

### Mirror of PartitiveRelation

```
GenericRelation
  +comprehensive: ConceptRef [1]              # the genus concept
  +members:       GenericMember [2..*]        # the species concepts
  +completeness:  Completeness [0..1]
  +criterion:     LocalizedString [0..1]      # the subdivision principle
  +sources:       ConceptSource [0..*]
  +notes:         LocalizedString [0..1]
  +status:        ConceptStatus [0..1]
```

### Comprehensive field naming

For both PartitiveRelation and GenericRelation, the wire field name is
`comprehensive`. For Generic, it denotes the genus concept (the
superordinate in a generic rake). Documented, not encoded differently.

This avoids a `genus` vs `comprehensive` split that would fork validators
and parsers for no semantic gain.

### Members field naming

Unified wire name `members` across all n-ary relation types. The `type`
field discriminates:

```yaml
type: partitive_relation   # or generic_relation
comprehensive: { ... }
members: [ ... ]
```

### Multiple criteria per comprehensive

The OIML pattern: one comprehensive (5.1) has 6 GenericRelations, each
with a distinct criterion. The validator rule (already enforced for
Partitive): two relations on the same comprehensive with the same
criterion are duplicates; two with different criteria are distinct
decompositions.

### ExternalConcept as comprehensive

Both OIML examples ("(quantity expressed by a measurement unit)" and
"(precision condition of measurement)") have ExternalConcept placeholders
as the *comprehensive* (top) of a generic rake. The current model handles
this: ExternalConcept lives at `concepts/<id>.yaml` with `status: external`;
the relation file references it normally via `comprehensive: ConceptRef`.

The validator `check-external-as-comprehensive` warns when such an
ExternalConcept lacks a `provided_by` edge (the decomposition dangles
without eventual resolution).

## Validation rules

Port of PartitiveRelation rules:

1. **Cardinality:** ≥2 members (ISO 704 "two or more")
2. **Duplicate criterion:** no two GenericRelations on the same
   comprehensive with the same criterion
3. **Missing criterion warning:** when multiple relations exist and any
   lacks criterion
4. **Invalid MECE combo:** presence: optional + count: at_least_one
   is rejected (collapses to optional+multiple)
5. **Delimiting+optional warning:** a delimiting part should be required

## Cross-references

- [Abstract N-ary Relation](abstract-nary-relation.md)
- [Relations as Files](relations-as-files.md)
- [ISO 704:2022 Mapping](iso704-2022-mapping.md)
