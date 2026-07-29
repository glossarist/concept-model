# ISO 704:2022 ↔ Glossarist Mapping

## Status

Reference — 2026-07-29. Living document.

## Purpose

ISO 704:2022 is a *methodology* standard for terminology work. Glossarist
is a *data model* with tooling. The two operate at different layers, and
a 1:1 mapping is the wrong target.

This document makes the mapping explicit: where we cover ISO 704, where
we exceed it, where we deliberately diverge.

## Coverage summary

| ISO 704:2022 concept | Section | Glossarist coverage | Status |
|---|---|---|---|
| Concept | §4 | `ManagedConcept` | Direct |
| Designation | §4.5 | `Designation` hierarchy | Direct |
| Definition | §5.3 | `DetailedDefinition` | Direct, with `type` field |
| Intensional definition | §5.3.1 | `DetailedDefinition.type: intensional` | New |
| Extensional definition | §5.3.2 | `DetailedDefinition.type: extensional` | New |
| Partitive definition | §5.3.3 | `DetailedDefinition.type: partitive` | New |
| Translated definition | §5.3.4 | `DetailedDefinition.type: translated` | New |
| Concept system | §5.4 | `domains` + `tags` + relation graph | Covered differently |
| Generic relation | §5.5.4.1 | `GenericRelation` (n-ary) + binary `broader_generic` | New (n-ary) |
| Associative relation | §5.5.4.2 | Binary `related` (50+ types) | Sufficient |
| Partitive relation | §5.5.4.3 | `PartitiveRelation` (n-ary) + binary `has_part` | Existing |
| Diagram notation | §5.5.4.x | `presence` + `count` MECE on members | Existing |
| Delimiting part | §5.5.4.2.2 | `is_delimiting` on members | Existing |
| Inheritance principle | §6.4 | Implicit in intensional definitions | Not modeled |
| Characteristic | §5.3 | Implicit in definition prose | Not modeled |
| Individual concept | §4.3 | Methodological distinction | Not promoted |
| Proper names | §4.5 | Methodological distinction | Not added |

## Where we exceed ISO 704

### Multi-dataset resolution (ExternalConcept)
- ISO 704 has no equivalent
- Glossarist: `status: external` + `provides` / `provided_by` resolution
- Cross-collection concept sharing

### Lifecycle governance
- ISO 704 is silent on governance
- Glossarist: `ConceptStatus` with 8 values (draft, submitted, not_valid,
  invalid, valid, superseded, retired, external)

### Source lineage
- ISO 704 doesn't model provenance
- Glossarist: `ConceptSource` with `type: lineage` and recursive
  `sourced_from` chain

### Multi-language as first-class
- ISO 704 mentions translation; doesn't structure it
- Glossarist: `LocalizedConcept` per language, fully modeled

### Rich binary relation taxonomy
- ISO 704 has ~3 binary types
- Glossarist: 50+ types covering SKOS, ISO 10241-1, ISO 25964, ISO 19135,
  ISO 12620, TBX

## Where we deliberately diverge

### ConceptSystem as entity
- ISO 704 §5.4 describes "concept system" methodologically
- Glossarist does NOT add a ConceptSystem class
- Reason: our `domains` + `tags` + relation graph already capture the
  same semantics. A new entity would duplicate them.
- See [relations-as-files design](relations-as-files.md) for how
  concept-system membership emerges from data structure.

### Inheritance principle as computed walk
- ISO 704 §6.4 describes inheritance as a reasoning principle
- Glossarist does NOT compute inherited characteristics
- Reason: characteristics are in intensional definition prose.
  Computing them as a derived walk duplicates data already in definitions.

### Characteristic as structured data
- ISO 704 §5.3 introduces "characteristic" as a methodological unit
- Glossarist does NOT model Characteristic as a class
- Reason: characteristics are encoded in definition prose. Structuring
  them as data is heavy and rarely useful for tools.

### Individual vs general concept
- ISO 704 §4.3 distinguishes them methodologically
- Glossarist does NOT add a `concept_type` field
- Reason: "individual concept" is a property of the designation (proper
  name), not the concept. Promoting it to concept level conflates two
  concerns.

### AssociativeRelation as n-ary class
- ISO 704 §5.5.4.2 shows associative rakes in diagrams
- Glossarist does NOT add an AssociativeRelation n-ary class
- Reason: no real-world evidence of associative rakes in our datasets.
  Binary `related` covers observed cases. Will revisit if a dataset
  shows associative rakes with role-bearing members.

## Associative taxonomy (ISO 704 Table 1)

ISO 704:2022 Table 1 enumerates ~30 associative relation subtypes. Our
`RelatedConceptType` enum covers most via existing values:

| ISO 704 Table 1 type | Our enum value |
|---|---|
| Symmetric: cause-effect | `related_concept` (general) |
| Asymmetric: agent-patient | `related_concept` |
| Sequential | `sequentially_related` |
| Spatial | `spatially_related` |
| Temporal | `temporally_related` |
| Comparative | `compare`, `contrast` |
| Lexical: homograph | `homograph` |
| Lexical: false friend | `false_friend` |
| ... | ... |

The full mapping is in `ontologies/taxonomies/relationship-type.ttl`
(scopeNotes cross-reference ISO 704 Table 1 entries). Missing types
are added case-by-case when datasets need them.

## Conclusion

ISO 704:2022 is one input to the Glossarist model, not the ceiling.
We adopt structures that add real data value (definition types,
generic rake, MECE on members). We document mappings where our
existing structures cover the same ground differently (concept
systems, associative taxonomy). We deliberately diverge where ISO
704's methodology doesn't translate to data structures
(characteristic model, inheritance walk).
