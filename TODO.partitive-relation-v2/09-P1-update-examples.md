# 09 — P1: Rewrite examples 20–23; add new examples

## Problem

Existing examples 20–23 use the v1 shape (`partitive_hyperedges`,
`parts`, `enumeration`, `markers`, `content`). They need rewriting
for v2.

Also need new examples demonstrating:
- Per-partitive certainty (mixed confirmed/possible)
- Type-shared plurality with `shared_type` filled in
- ExternalConcept as a partitive
- A comprehensive with two distinct PartitiveRelations (different
  criteria)
- Criterion coherence validation

## Scope

- Rewrite: `schemas/v3/examples/20-23-*.yaml`
- New: `schemas/v3/examples/24-29-*.yaml`
- Update: `schemas/v3/examples/_negative/*.yaml` for new field names
- Update: `schemas/v3/examples/README.md` coverage table

## Concrete examples

### 20 — Closed, type-shared plurality (rewritten)

```yaml
# 20 — Partitive Relation (complete, type-shared plurality)
#
# Source analogue: VIM 2012 Fig. A.6 — measurement result (2.9) is
# composed of measured quantity value (2.10) and measurement
# uncertainty (2.26); these are all the parts.
---
id: "112-02-09"
data:
  identifier: "112-02-09"
  localized_concepts:
    eng: 22222222-aaaa-bbbb-cccc-000000000009
  domains:
    - concept_id: section-2
      source: "VIM"
      ref_type: section

partitive_relations:
  - comprehensive:
      source: "VIM"
      id: "112-02-09"
    partitives:
      - ref: { source: "VIM", id: "112-02-10" }
      - ref: { source: "VIM", id: "112-03-26" }
    completeness: complete
    plurality:
      is_shared: true
    criterion:
      eng: measurement result composition
      fra: composition du résultat de mesure

status: valid
date_accepted: "2012-01-01T00:00:00+00:00"
---
# localized concept doc unchanged
```

### 21 — Partial, no plurality (rewritten)

```yaml
# 21 — Partitive Relation (partial decomposition)
#
# Source analogue: VIM 2012 — system of quantities (1.3) has at
# least these parts; others exist but are not encoded.
---
id: "112-01-03"
data:
  identifier: "112-01-03"
  localized_concepts:
    eng: 22222222-aaaa-bbbb-cccc-000000000031
  domains:
    - concept_id: section-1
      source: "VIM"
      ref_type: section

partitive_relations:
  - comprehensive:
      source: "VIM"
      id: "112-01-03"
    partitives:
      - ref: { source: "VIM", id: "112-01-04" }
      - ref: { source: "VIM", id: "112-01-05" }
      - ref: { source: "VIM", id: "112-01-22" }
    completeness: partial
    criterion:
      eng: quantity system decomposition

status: valid
date_accepted: "2012-01-01T00:00:00+00:00"
```

### 22 — Mixed certainty (rewritten; demonstrates per-partitive certainty)

```yaml
# 22 — Partitive Relation (mixed per-partitive certainty)
#
# VIM 2007 Fig. A.2 — system of quantities (1.3) rake with two
# confirmed partitives (1.4, 1.5) and one possible partitive (1.22)
# whose membership is uncertain.
---
id: "112-01-03"
data:
  identifier: "112-01-03"
  # ...
partitive_relations:
  - comprehensive:
      source: "VIM"
      id: "112-01-03"
    partitives:
      - ref: { source: "VIM", id: "112-01-04" }
        certainty: confirmed
      - ref: { source: "VIM", id: "112-01-05" }
        certainty: confirmed
      - ref: { source: "VIM", id: "112-01-22" }
        certainty: possible
    completeness: partial
    criterion:
      eng: quantity classification

status: valid
date_accepted: "2012-01-01T00:00:00+00:00"
```

### 23 — Plain closed (rewritten)

```yaml
# 23 — Partitive Relation (plain complete decomposition)
#
# A simple closed decomposition: the comprehensive is composed of
# exactly two parts, no plurality claim, no per-partitive
# uncertainty. The minimal v2 form.
---
id: "113-01-01"
data:
  identifier: "113-01-01"
  # ...
partitive_relations:
  - comprehensive:
      source: "EXAMPLE"
      id: "113-01-01"
    partitives:
      - ref: { source: "EXAMPLE", id: "113-01-02" }
      - ref: { source: "EXAMPLE", id: "113-01-03" }
    # completeness omitted → defaults to complete
    # criterion omitted → reviewer note (no sibling relation to distinguish)
```

### 24 — ExternalConcept as a partitive (new)

```yaml
# 24 — Partitive Relation with an ExternalConcept as a partitive
#
# Demonstrates: a comprehensive whose partitives include an
# external concept (status: external). The external concept is
# defined in concepts/ext-qft.yaml in this example dataset.

# Companion file: schemas/v3/examples/_external/ext-qft.yaml
# (see item 06)

---
id: "114-01-01"
data:
  identifier: "114-01-01"
  # ...
partitive_relations:
  - comprehensive:
      source: "EXAMPLE"
      id: "114-01-01"
    partitives:
      - ref: { source: "EXAMPLE", id: "114-01-02" }
        certainty: confirmed
      - ref: { source: "EXAMPLE", id: "ext-qft" }
        certainty: possible
    completeness: partial
    criterion:
      eng: theoretical decomposition

status: valid
date_accepted: "2026-07-23T00:00:00+00:00"
```

### 25 — Type-shared plurality with shared_type filled in (new)

```yaml
# 25 — Partitive Relation with shared_type
#
# Three partitives of the same type; the type is known and
# explicitly recorded (Glossarist extension — ISO notation
# doesn't encode the type).
---
id: "115-01-01"
data:
  identifier: "115-01-01"
partitive_relations:
  - comprehensive:
      source: "EXAMPLE"
      id: "115-01-01"
    partitives:
      - ref: { source: "EXAMPLE", id: "115-01-02" }
      - ref: { source: "EXAMPLE", id: "115-01-03" }
      - ref: { source: "EXAMPLE", id: "115-01-04" }
    completeness: complete
    plurality:
      is_shared: true
      shared_type: { source: "EXAMPLE", id: "115-01-05" }

status: valid
```

### 26 — Two distinct decompositions of the same comprehensive (new)

```yaml
# 26 — Same comprehensive, different criteria
#
# Demonstrates criterion coherence: two PartitiveRelations on the
# same comprehensive, distinguished by criterion. The coherence
# validator (item 13) accepts this because criteria differ.
---
id: "116-01-01"
data:
  identifier: "116-01-01"
partitive_relations:
  - comprehensive:
      source: "EXAMPLE"
      id: "116-01-01"
    partitives:
      - ref: { source: "EXAMPLE", id: "116-01-02" }
      - ref: { source: "EXAMPLE", id: "116-01-03" }
    completeness: complete
    criterion:
      eng: physical structure
  - comprehensive:
      source: "EXAMPLE"
      id: "116-01-01"
    partitives:
      - ref: { source: "EXAMPLE", id: "116-01-04" }
      - ref: { source: "EXAMPLE", id: "116-01-05" }
    completeness: complete
    criterion:
      eng: functional subsystem

status: valid
```

### 27 — ExternalConcept file (new)

```yaml
# schemas/v3/examples/_external/ext-qft.yaml
# Companion to example 24.
id: ext-qft
status: external
data:
  identifier: ext-qft
  designations:
    - designation: "quantum field theory"
      type: expression
      normative_status: admitted
# When another dataset defining this concept is loaded, the
# collection manager adds a `provided_by` edge:
# related:
#   - type: provided_by
#     ref: { source: urn:other-dataset, id: "..." }
status: external
date_accepted: "2026-07-23T00:00:00+00:00"
```

### 28 — ExternalConcept with provided_by edge (new)

```yaml
# 28 — ExternalConcept resolved via provided_by
#
# Demonstrates: an ExternalConcept whose resolution was found in
# another dataset. The provided_by edge was added by the
# collection manager.
---
id: ext-resolved
status: external
data:
  identifier: ext-resolved
  designations:
    - designation: "measurement uncertainty"
      type: expression
related:
  - type: provided_by
    ref: { source: urn:vim:2012, id: "112-03-26" }

status: external
date_accepted: "2026-07-23T00:00:00+00:00"
```

### 29 — Plurality uncertain (new)

```yaml
# 29 — Type-shared plurality with uncertainty
#
# ISO 704 broken line: type-shared plurality exists but its
# boundaries (which partitives, how many) are uncertain.
---
id: "117-01-01"
data:
  identifier: "117-01-01"
partitive_relations:
  - comprehensive:
      source: "EXAMPLE"
      id: "117-01-01"
    partitives:
      - ref: { source: "EXAMPLE", id: "117-01-02" }
      - ref: { source: "EXAMPLE", id: "117-01-03" }
    completeness: partial
    plurality:
      is_shared: true
      is_uncertain: true
      shared_type: { source: "EXAMPLE", id: "117-01-04" }

status: valid
```

## Negative examples (update + new)

Update existing `_negative/*.yaml` files to use new field names:

```yaml
# _negative/01-missing-comprehensive.yaml (updated)
id: "900-01-01"
data:
  identifier: "900-01-01"
partitive_relations:                      # was: partitive_hyperedges
  - partitives:                            # was: parts
      - ref: { source: "X", id: "900-01-02" }   # was: { source: "X", id: "..." }
    completeness: complete                 # was: enumeration: closed
status: valid
```

New negative examples:

```yaml
# _negative/10-single-partitive.yaml
# ISO requires "two or more" partitives.
id: "900-10-01"
data:
  identifier: "900-10-01"
partitive_relations:
  - comprehensive: { source: "X", id: "900-10-01" }
    partitives:
      - ref: { source: "X", id: "900-10-02" }
    completeness: complete
status: valid

# _negative/11-duplicate-criterion.yaml
# Two PartitiveRelations on the same comprehensive with identical
# criterion — duplicate decomposition.
id: "900-11-01"
data:
  identifier: "900-11-01"
partitive_relations:
  - comprehensive: { source: "X", id: "900-11-01" }
    partitives:
      - ref: { source: "X", id: "900-11-02" }
    criterion: { eng: physical structure }
  - comprehensive: { source: "X", id: "900-11-01" }
    partitives:
      - ref: { source: "X", id: "900-11-03" }
    criterion: { eng: physical structure }
status: valid

# _negative/12-external-with-definition.yaml
# An ExternalConcept with a definition contradicts itself — if you
# have a definition, status should be valid (or other non-external).
id: ext-bad
status: external
data:
  identifier: ext-bad
  designations:
    - designation: "bad external"
      type: expression
  definition:
    - content: "This shouldn't be here for an external concept."
status: external
```

## README coverage table

Update `schemas/v3/examples/README.md`:

| # | Topic | File |
|---|-------|------|
| 20 | Complete + type-shared plurality | `20-partitive-relation-closed.yaml` |
| 21 | Partial, no plurality | `21-partitive-relation-partial.yaml` |
| 22 | Mixed per-partitive certainty | `22-partitive-relation-mixed-certainty.yaml` |
| 23 | Plain complete (minimal) | `23-partitive-relation-plain.yaml` |
| 24 | ExternalConcept as a partitive | `24-partitive-relation-external.yaml` |
| 25 | Type-shared plurality with shared_type | `25-partitive-relation-shared-type.yaml` |
| 26 | Two decompositions, distinct criteria | `26-partitive-relation-dual-criteria.yaml` |
| 27 | ExternalConcept file | `_external/ext-qft.yaml` |
| 28 | ExternalConcept resolved (provided_by) | `28-external-concept-resolved.yaml` |
| 29 | Plurality uncertain | `29-partitive-relation-plurality-uncertain.yaml` |

## Verification

```bash
make validate
bundle exec exe/validate-negative-examples
```

## Status: pending
