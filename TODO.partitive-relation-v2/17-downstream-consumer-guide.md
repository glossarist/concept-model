# 17 — Downstream consumer guide

This document tells every downstream consumer of glossarist
concept-model how to handle the v2 PartitiveRelation redesign.

## Affected consumers

| Consumer | What it does | Impact |
|----------|-------------|--------|
| **glossarist-ruby** | V3 model, deserialization, RDF emission, validation rules | **Major**: model rewrite, new classes, enum renames |
| **glossarist-js** | Concept model, parser, serializer, diff, resolver, validator, TS types | **Major**: same scope as Ruby |
| **concept-browser** | Data pipeline, UI components, stats | **Medium**: pipeline + UI updates for new shape |
| **vocab datasets** | Existing YAML using `partitive_hyperedges` | **Medium**: migration script + manual review |
| **External RDF consumers** | Read glossarist JSON-LD output | **Minor**: term renames; versioned context handles transition |

## Coordination timeline

```
T0: concept-model v2 ships (this plan)
    ↓ (1-2 days)
T1: glossarist-ruby updates V3 model
    ↓ (parallel)
T1: glossarist-js updates Concept model
    ↓ (after both consumers are updated)
T2: concept-browser data pipeline + UI
    ↓ (parallel)
T2: vocab datasets migrate via script
    ↓ (after migration)
T3: concept-model drops v1 backward-compat (next major release)
```

**Lockstep requirement**: glossarist-ruby and glossarist-js must
ship their v2 support BEFORE vocab datasets migrate. Otherwise
migrated data is unreadable.

---

## glossarist-ruby

### Files to update

```
lib/glossarist/v3/
  managed_concept.rb            # rename partitive_hyperedges → partitive_relations
  managed_concept_data.rb       # same
  partitive_hyperedge.rb        # DELETE; replaced by partitive_relation.rb
  partitive_enumeration.rb      # DELETE; replaced by completeness.rb
  plurality_marker.rb           # DELETE; replaced by member_certainty.rb + type_shared_plurality.rb
  partitive_relation.rb         # NEW
  partitive_member.rb           # NEW
  type_shared_plurality.rb      # NEW
  completeness.rb               # NEW
  member_certainty.rb           # NEW
  related_concept_type.rb       # ADD provides, provided_by values

lib/glossarist/v3.rb            # update autoloads

lib/glossarist/glossary_definition.rb  # update config.yml SSOT lists:
                                        # - PARTITIVE_ENUMERATION_VALUES → COMPLETENESS_VALUES
                                        # - PLURALITY_MARKER_VALUES → MEMBER_CERTAINTY_VALUES (different semantics)

config.yml                      # rename + add new enum lists

lib/glossarist/validation/rules/
  partitive_hyperedge_rule.rb   # RENAME to partitive_relation_rule.rb
  partitive_relation_rule.rb    # NEW (replaces above; new validation logic)

lib/glossarist/rdf/
  gloss_hyperedge.rb            # RENAME to gloss_partitive_relation.rb
  gloss_partitive_relation.rb   # NEW (replaces above)
  gloss_concept.rb              # update members :hyperedges → :partitive_relations
  gloss_member.rb               # NEW (RDF view for PartitiveMember)
  gloss_type_shared_plurality.rb # NEW

lib/glossarist/rdf.rb           # update autoloads
lib/glossarist/rdf/v3.rb        # update autoloads

lib/glossarist/transforms/
  concept_to_gloss_transform.rb # emit new property names

lib/glossarist/schema_migration/
  v2_to_v3.rb                   # no change (v2→v3 path is unaffected)
  v3_hyperedge_rewrite.rb       # NEW (v3-old → v3-new migration in Ruby)

spec/unit/v3/
  partitive_hyperedge_spec.rb   # RENAME to partitive_relation_spec.rb
  partitive_relation_spec.rb    # NEW (rewritten)
  managed_concept_data_spec.rb  # update references

spec/unit/validation/rules/
  partitive_hyperedge_rule_spec.rb  # RENAME
  partitive_relation_rule_spec.rb   # NEW

spec/unit/integration/
  cross_repo_hyperedge_spec.rb  # RENAME to cross_repo_partitive_relation_spec.rb

CLAUDE.md                       # update PartitiveHyperedge section → PartitiveRelation
```

### Model class sketch

```ruby
# lib/glossarist/v3/partitive_relation.rb
module Glossarist
  module V3
    class PartitiveRelation < GlossaryDefinition
      attribute :comprehensive, ReferenceToTermbase
      attribute :partitives, PartitiveMember, collection: true
      attribute :completeness, :string, values: Completeness::VALUES
      attribute :plurality, TypeSharedPlurality
      attribute :criterion, LocalizedString  # multilingual hash

      def complete? = completeness == Completeness::COMPLETE
      def partial?  = completeness == Completeness::PARTIAL

      def coordinate? = partitives.size >= 2

      # no `content` attribute — structural edges don't carry prose
    end
  end
end
```

```ruby
# lib/glossarist/v3/partitive_member.rb
module Glossarist
  module V3
    class PartitiveMember < GlossaryDefinition
      attribute :ref, ReferenceToTermbase
      attribute :certainty, :string, values: MemberCertainty::VALUES,
        default: MemberCertainty::CONFIRMED

      def confirmed? = certainty == MemberCertainty::CONFIRMED
      def possible?  = certainty == MemberCertainty::POSSIBLE
    end
  end
end
```

### Config SSOT

```yaml
# config.yml
completeness:
  value:
    - complete
    - partial

member_certainty:
  value:
    - confirmed
    - possible

# DELETE:
# partitive_enumeration:
#   value: [closed, open]
# plurality_marker:
#   value: [double, dashed]
```

### Validation rule

```ruby
# lib/glossarist/validation/rules/partitive_relation_rule.rb
module Glossarist
  module Validation
    module Rules
      class PartitiveRelationRule < Base
        code :gls_partitive_relation

        def call(concept)
          relations = concept.partitive_relations
          return [] if relations.empty?

          errors = []

          # Cardinality: ≥2 partitives
          relations.each_with_index do |rel, i|
            if rel.partitives.size < 2
              errors << error(concept, "partitive_relations[#{i}] needs ≥2 partitives (ISO 704)")
            end
          end

          # Duplicate (comprehensive + criterion)
          grouped = relations.group_by { |r| [r.comprehensive, r.criterion] }
          grouped.each do |(comp, crit), group|
            next if group.size == 1 || crit.nil?
            errors << error(concept, "duplicate PartitiveRelation for #{comp.inspect} with criterion #{crit.inspect}")
          end

          # Plurality coherence
          relations.each_with_index do |rel, i|
            plural = rel.plurality
            next unless plural
            if plural.is_uncertain && !plural.is_shared
              errors << error(concept, "partitive_relations[#{i}].plurality: is_uncertain requires is_shared")
            end
          end

          errors
        end
      end
    end
  end
end
```

### Specs (minimum coverage)

```ruby
# spec/unit/v3/partitive_relation_spec.rb
module Glossarist
  module V3
    RSpec.describe PartitiveRelation do
      let(:comprehensive) { ReferenceToTermbase.new(source: "X", id: "1") }
      let(:partitive_a)   { PartitiveMember.new(ref: ReferenceToTermbase.new(source: "X", id: "2")) }
      let(:partitive_b)   { PartitiveMember.new(ref: ReferenceToTermbase.new(source: "X", id: "3")) }

      it "constructs with comprehensive + 2 partitives" do
        rel = described_class.new(comprehensive: comprehensive, partitives: [partitive_a, partitive_b])
        expect(rel.complete?).to be true  # default
        expect(rel.coordinate?).to be true
      end

      it "rejects < 2 partitives via validation rule" do
        # (validation rule tested in its own spec)
      end

      it "round-trips through YAML" do
        rel = described_class.new(
          comprehensive: comprehensive,
          partitives: [partitive_a, partitive_b],
          completeness: "partial",
          criterion: { eng: "physical structure" }
        )
        yaml = rel.to_yaml
        restored = described_class.from_yaml(yaml)
        expect(restored.partitives.map { |m| m.ref.id }).to eq(%w[2 3])
        expect(restored.criterion["eng"]).to eq("physical structure")
      end
    end
  end
end
```

### Migration script (in-repo)

Bundle a Ruby migration alongside the concept-model Ruby script:

```ruby
# lib/glossarist/schema_migration/v3_hyperedge_rewrite.rb
module Glossarist
  module SchemaMigration
    module V3HyperedgeRewrite
      def self.call(hash)
        return hash unless hash.key?("partitive_hyperedges")

        hash["partitive_relations"] = hash.delete("partitive_hyperedges").map do |old|
          {
            "comprehensive" => old["comprehensive"],
            "partitives" => (old["parts"] || []).map { |ref| { "ref" => ref } },
            "completeness" => old["enumeration"] == "open" ? "partial" : "complete",
          }.tap do |new|
            markers = Array(old["markers"])
            unless markers.empty?
              new["plurality"] = {
                "is_shared" => markers.include?("double"),
                "is_uncertain" => markers.include?("dashed"),
              }
            end
          end
        end

        hash
      end
    end
  end
end
```

Wire into `ManagedConcept.from_yaml` to accept v1-shape input transparently for one release cycle.

---

## glossarist-js

### Files to update

```
src/models/
  partitive-hyperedge.js         # DELETE; replaced by partitive-relation.js
  partitive-relation.js          # NEW
  partitive-member.js            # NEW
  type-shared-plurality.js       # NEW
  completeness.js                # NEW (constants + validator)
  member-certainty.js            # NEW
  partitive-enumeration.js       # DELETE
  plurality-marker.js            # DELETE
  concept.js                     # rename property
  index.js                       # update exports
  index.d.ts                     # update TS declarations

src/concept-parser.js            # parse new shape
src/concept-serializer.js        # serialize new shape
src/diff/concept-diff.js         # diff new shape
src/reference-resolver.js        # resolve new ref shape
src/validators/
  partitive-hyperedge-rule.js    # RENAME to partitive-relation-rule.js
  partitive-relation-rule.js     # NEW
  index.js                       # update _default registry

test/models/
  partitive-hyperedge.test.js    # RENAME to partitive-relation.test.js
  partitive-relation.test.js     # NEW

test/integration/
  hyperedge-roundtrip.test.js   # RENAME to partitive-relation-roundtrip.test.js
```

### Model class sketch

```javascript
// src/models/partitive-relation.js
'use strict';

const { ConceptRef } = require('./concept-ref');
const { PartitiveMember } = require('./partitive-member');
const { TypeSharedPlurality } = require('./type-shared-plurality');
const { COMPLETENESS_VALUES, MEMBER_CERTAINTY_VALUES } = require('./enums');

class PartitiveRelation {
  constructor(data = {}) {
    this.comprehensive = new ConceptRef(data.comprehensive ?? {});
    this.partitives = (data.partitives ?? []).map(p => new PartitiveMember(p));
    this.completeness = data.completeness ?? 'complete';
    this.plurality = data.plurality ? new TypeSharedPlurality(data.plurality) : null;
    this.criterion = data.criterion ?? null;

    this._validate();
  }

  _validate() {
    if (!this.comprehensive.source && !this.comprehensive.id && !this.comprehensive.text) {
      throw new Error('PartitiveRelation.comprehensive must not be empty');
    }
    if (this.partitives.length < 2) {
      throw new Error('PartitiveRelation needs ≥2 partitives (ISO 704)');
    }
    if (!COMPLETENESS_VALUES.includes(this.completeness)) {
      throw new Error(`Invalid completeness: ${this.completeness}`);
    }
  }

  get isComplete() { return this.completeness === 'complete'; }
  get isPartial()  { return this.completeness === 'partial'; }

  toJSON() {
    return {
      comprehensive: this.comprehensive.toJSON(),
      partitives: this.partitives.map(p => p.toJSON()),
      completeness: this.completeness,
      ...(this.plurality ? { plurality: this.plurality.toJSON() } : {}),
      ...(this.criterion ? { criterion: this.criterion } : {}),
    };
  }

  static fromJSON(json) {
    return new PartitiveRelation(json);
  }
}

module.exports = { PartitiveRelation };
```

### Backward-compat reader

For one release cycle, the parser accepts both v1 and v2 shapes:

```javascript
// src/concept-parser.js (excerpt)
function parsePartitiveRelations(data) {
  // v2 shape
  if (data.partitive_relations) {
    return data.partitive_relations.map(r => new PartitiveRelation(r));
  }
  // v1 shape (legacy)
  if (data.partitive_hyperedges) {
    return data.partitive_hyperedges.map(migrateV1ToV2).map(r => new PartitiveRelation(r));
  }
  return [];
}

function migrateV1ToV2(old) {
  return {
    comprehensive: old.comprehensive,
    partitives: (old.parts || []).map(ref => ({ ref })),
    completeness: old.enumeration === 'open' ? 'partial' : 'complete',
    ...(old.markers && old.markers.length ? {
      plurality: {
        is_shared: old.markers.includes('double'),
        is_uncertain: old.markers.includes('dashed'),
      }
    } : {}),
  };
}
```

The serializer emits only v2 shape (`partitive_relations`). After
one release cycle, drop the v1 reader.

---

## concept-browser

### Files to update

```
src/adapters/types.ts           # rename interfaces
src/adapters/GraphDataSource.ts # update loadHyperedges → loadPartitiveRelations
src/composables/use-concept-edges.ts  # update computed

scripts/
  generate-data.mjs             # update emit shape
  build-edges.js                # update extractor name + logic
  migrate-vocab-data.mjs        # update migration helper

src/components/
  PartitiveHyperedgeList.vue    # RENAME to PartitiveRelationList.vue
  PartitiveRelationList.vue     # NEW (rewritten)

src/__tests__/
  partitive-hyperedge.test.ts   # RENAME to partitive-relation.test.ts
  partitive-relation.test.ts    # NEW

site-config.example.yml         # update format contract
```

### Data pipeline shape

```javascript
// dist/data/<dataset>/partitive_relations.json
[
  {
    "comprehensive": { "source": "urn:vim:2012", "id": "112-02-09" },
    "partitives": [
      { "ref": { "source": "urn:vim:2012", "id": "112-02-10" }, "certainty": "confirmed" },
      { "ref": { "source": "urn:vim:2012", "id": "112-03-26" }, "certainty": "confirmed" }
    ],
    "completeness": "complete",
    "plurality": { "is_shared": true },
    "criterion": { "eng": "measurement result composition" }
  }
]
```

### UI rendering

`PartitiveRelationList.vue` shows:
- Comprehensive as card title
- Each partitive as a child row, with `certainty: possible` grayed
  or dashed (matches ISO 704 notation)
- Completeness badge: COMPLETE (green) / PARTIAL (yellow)
- Plurality badge: SHARED TYPE / SHARED TYPE (UNCERTAIN) when
  `is_uncertain`
- Criterion as italic text under the title

External concepts (when referenced as partitives) show an
"external" badge. If `provided_by` exists, link to the resolving
concept.

### Stats

```json
{
  "partitiveRelations": {
    "count": 32,
    "byCompleteness": { "complete": 25, "partial": 7 },
    "byMemberCertainty": { "confirmed": 65, "possible": 12 },
    "withCriterion": 28,
    "withoutCriterion": 4,
    "withPlurality": 18,
    "externalConcepts": 3,
    "resolvedExternals": 1
  }
}
```

---

## vocab datasets

### Migration

Run `concept-model`'s migration script:

```bash
git clone https://github.com/glossarist/concept-model
cd concept-model
bundle install

bundle exec exe/migrate-to-partitive-relation-v2 --dry-run ../vocab/datasets/vim-2012/concepts/
# review output, then:
bundle exec exe/migrate-to-partitive-relation-v2 --backup ../vocab/datasets/vim-2012/concepts/
```

### Manual review checklist

After migration, for each concept that gained a `partitive_relations`
block:

1. **Read the source VIM diagram** (if available). For relations
   with `[dashed]` markers, mark specific partitives as
   `certainty: possible` based on which tooth the dashed line
   actually qualified.

2. **Fill in `criterion`** for relations sharing a comprehensive
   with other relations. The criterion distinguishes them.

3. **Fill in `plurality.shared_type`** for relations with
   `is_shared: true` where the shared type is known from context.

4. **Move `content` field to comprehensive's notes** if the prose
   was valuable. Otherwise drop it.

5. **Run validators**:
   ```bash
   bundle exec exe/check-partitive-relation-coherence
   bundle exec exe/check-external-concept-shape
   bundle exec exe/check-binary-has-part-redundancy
   ```

### Estimated effort

- ~32 hyperedges across 3 VIM datasets (vim-2007, vim-2010, vim-2012)
- ~5 minutes per relation for review
- ~3 hours total manual review

### Coordination with concept-browser release

Datasets must migrate AFTER concept-browser ships v2 support.
Otherwise the data pipeline can't read the new shape.

---

## External RDF consumers

### Term renames

| v1 term | v2 term |
|---------|---------|
| `gloss:PartitiveHyperedge` | `gloss:PartitiveRelation` |
| `gloss:hasPartitiveHyperedge` | `gloss:hasPartitiveRelation` |
| `gloss:PartitiveEnumeration` | `gloss:Completeness` (as ConceptScheme) |
| `gloss:PluralityMarker` | (deleted; replaced by `gloss:TypeSharedPlurality` class) |
| `gloss:enumeration` | `gloss:completeness` |
| `gloss:hasPart` | `gloss:hasPartitive` (range now PartitiveMember, not ConceptRef) |
| `gloss:hasPluralityMarker` | `gloss:hasPlurality` |
| `gloss:hyperedgeContent` | (deleted) |

### Versioned context

The JSON-LD context file (`ontologies/glossarist.context.jsonld`)
is versioned by Git tag. Consumers that pinned a specific tag keep
getting v1 terms; consumers that follow `main` get v2 terms.

Recommendation for external consumers: pin to a specific tag
(e.g., `v3.2.0`) until you've updated your code for v2. Then bump.

### SKOS scheme URIs

| v1 scheme | v2 scheme |
|-----------|-----------|
| `gloss:partitiveEnumeration` | `gloss:completeness` |
| `gloss:pluralityMarker` | (deleted; not an enum anymore) |

External consumers that hard-coded the v1 URIs need to update.
Those that resolved via the JSON-LD context update automatically.

---

## Rollout checklist

- [ ] concept-model v2 merged + tagged (this plan)
- [ ] glossarist-ruby v2 support merged + released
- [ ] glossarist-js v2 support merged + released
- [ ] concept-browser v2 support merged + released
- [ ] vocab datasets migrated (vim-2007, vim-2010, vim-2012)
- [ ] External RDF consumers notified (email, issue tracker)
- [ ] concept-model drops v1 backward-compat in next major release

## Status: tracking only — execute in respective repos
