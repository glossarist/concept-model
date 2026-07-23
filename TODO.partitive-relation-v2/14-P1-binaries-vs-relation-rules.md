# 14 — P1: Binary `has_part` vs PartitiveRelation coexistence rules

## Problem

The same semantic concept (part-of) is modeled two different ways:

| | Binary edge | N-ary relation |
|---|------------|----------------|
| Wire form | `related: [{type: has_part, ref: X}]` | `partitive_relations: [{comprehensive, partitives, ...}]` |
| Cardinality | 1 comprehensive ↔ 1 partitive | 1 comprehensive ↔ 2+ partitives |
| Frequency | common (~1000s/dataset) | rare (~10s/dataset) |
| Metadata | type, ref | comprehensive, partitives, completeness, plurality, criterion |

The asymmetry is pragmatic (binary edges are compact; n-ary
relations carry more metadata). But it creates two failure modes:

1. **Redundancy**: a PartitiveRelation A → {b, c, d} plus binary
   `A has_part b`, `A has_part c`, `A has_part d` — same fact
   encoded twice
2. **Inconsistency**: binary edges can't carry completeness
   claims. A binary cluster asserting completeness is
   indistinguishable from one that's silent on completeness

## Decision: documentation + warning validator

The asymmetry stays. Documentation explains when to use each. A
warning validator catches the redundancy case.

### Documentation

Add to `docs/design/partitive-relation.md`:

## When to use binary `has_part` vs `PartitiveRelation`

Use **binary `has_part`** when:
- The assertion is a single pairwise fact: "A has part b"
- You make no claim about completeness
- You make no claim about plurality
- You don't need per-partitive certainty

Use **PartitiveRelation** when:
- The decomposition has 2+ partitives
- You want to assert completeness (closed/open)
- You want to record type-shared plurality
- You need per-partitive certainty
- You want to record the criterion of subdivision

**Do not duplicate**: if a PartitiveRelation asserts A → {b, c, d},
don't also have binary `has_part` edges for the same pairs. The
PartitiveRelation subsumes them.

### Validator: CheckBinaryHasPartRedundancy

```ruby
# lib/glossarist/concept_model/validators/check_binary_has_part_redundancy.rb
module Glossarist
  module ConceptModel
    module Validators
      class CheckBinaryHasPartRedundancy < Validator
        HAS_PART_TYPES = %w[has_part is_part_of].freeze

        def run
          warnings = []

          each_concept_yaml do |path, docs|
            doc = docs.first
            next unless doc.is_a?(Hash)

            relations = doc["partitive_relations"] || []
            related   = doc["related"] || []

            # Collect partitive refs from PartitiveRelations
            partitive_refs = relations.flat_map do |rel|
              (rel["partitives"] || []).map { |m| ref_key(m["ref"]) }
            end.to_set

            # Collect binary has_part refs
            binary_refs = related
              .select { |r| HAS_PART_TYPES.include?(r["type"]) }
              .map { |r| ref_key(r["ref"]) }
              .to_set

            # Redundancy: refs in both
            redundant = partitive_refs & binary_refs
            redundant.each do |ref|
              warnings << "#{path}: binary has_part edge for #{ref} is redundant (already in a PartitiveRelation)"
            end

            # Cluster warning: 3+ binary has_part edges from this concept
            if binary_refs.length >= 3
              warnings << "#{path}: #{binary_refs.length} binary has_part edges — consider converting to a PartitiveRelation"
            end
          end

          if warnings.empty?
            ok("OK: no binary has_part / PartitiveRelation redundancy")
          else
            # Warnings only — exit 0 so CI doesn't fail, but report
            warnings.each { |w| $stderr.puts "WARN: #{w}" }
            ok("OK: redundancy check complete (#{warnings.length} warnings, see stderr)")
          end
        end

        private

        def ref_key(ref)
          return nil unless ref.is_a?(Hash)
          "#{ref['source']}:#{ref['id']}"
        end

        def each_concept_yaml
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            yield path, YAML.load_stream(File.read(path))
          end
        end
      end
    end
  end
end
```

### Why warnings, not errors

- Some datasets legitimately have both forms for transitional reasons
  (migration in progress)
- The redundancy is harmless data-wise — just wasteful
- Forcing a hard error would block PRs that should land

A future tightening (after migration is complete) could promote
these to errors.

## Verification

```bash
bundle exec exe/check-binary-has-part-redundancy
```

## CI integration

Add as a warning-only job:

```yaml
  check-binary-has-part-redundancy:
    name: Check binary has_part / PartitiveRelation redundancy (warnings)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { ruby-version: '3.4', bundler-cache: true }
      - run: bundle exec exe/check-binary-has-part-redundancy
```

## Status: pending
