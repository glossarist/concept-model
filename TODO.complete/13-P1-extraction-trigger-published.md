# 13 — P1: Move extraction-trigger doc into published location

## Problem

The contributor's `glossarist-ruby/TODO.hyperedges/37-P2-concept-model-extraction-trigger.md`
appended a "HyperedgeRelationship base extraction trigger" section
to `TODO.hyperedge/00-design-overview.md`. That file is gitignored.

The doc is invisible to consumers.

## Fix

After item 02 publishes the design doc at
`docs/design/partitive-hyperedge.md`, ensure the extraction-trigger
section lands in the same published file.

```markdown
## Extraction trigger for `HyperedgeRelationship` base class

The current design has a single `PartitiveHyperedge` class. VIM and
ISO 10241-1 diagrams also have other n-ary constructs (generic
instantial, associative-multidimensional, etc.). We deferred
introducing a `HyperedgeRelationship` abstract base class as YAGNI.

**Extraction trigger:** when **three** hyperedge subclasses exist, do
the following refactor:

1. Introduce `HyperedgeRelationship < glossarist:Relationship` with
   the common fields (`comprehensive`, `parts`, `content`).
2. Move `PartitiveHyperedge` under it as a concrete subclass with
   the `enumeration` and `markers` fields specific to partitive
   decomposition.
3. Future hyperedge types (instantial, associative) inherit the base
   and add their own axes.

If only one or two hyperedge types exist, do not extract — the cost
of generalization exceeds the benefit of factoring out `comprehensive`
and `parts`.
```

## Verification

```bash
grep -n "Extraction trigger" docs/design/partitive-hyperedge.md
```

## Status: pending (depends on item 02)
