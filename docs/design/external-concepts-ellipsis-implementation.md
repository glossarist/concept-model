# External concepts + ellipsis — downstream implementation guide

> **For:** glossarist-ruby, glossarist-js, concept-browser
> **Source:** concept-model PR #91 (ConceptRef gains `external` + `ellipsis`)
> **Date:** 2026-08-03

## What concept-model shipped

ConceptRef now has five forms:

| Form | Wire shape | Semantic | Renders as |
|------|-----------|----------|------------|
| Resolved | `{source, id}` | Named concept in a dataset | `label` (clickable link) |
| Resolved + text | `{source, id, text}` | Named concept with display override | `text` (clickable) |
| Text-only | `{text}` | Lexical target (designation relationship) | `text` (no parens) |
| External | `{text, external: true}` | Parenthetical concept (ISO 704 parenthetic term) | `(text)` |
| Ellipsis | `{ellipsis: true}` | Known gap, unidentified target | `...` |

These appear in:
- Hyperedge member `ref` fields (PartitiveHyperedge, GenericHyperedge, SequentialHyperedge)
- Hyperedge `comprehensive` field
- Binary `related[].ref` fields
- `DesignationRelationship.target_concept`

---

## glossarist-ruby — what to do

### 1. V3::ConceptRef gains `external` and `ellipsis` attributes

```ruby
class ConceptRef < Lutaml::Model::Serializable
  attribute :source, :string
  attribute :id, :string
  attribute :text, :string
  attribute :external, :boolean, default: -> { false }
  attribute :ellipsis, :boolean, default: -> { false }

  key_value do
    map :source, to: :source
    map :id, to: :id
    map :text, to: :text
    map :external, to: :external
    map :ellipsis, to: :ellipsis
  end
end
```

### 2. Predicates on ConceptRef

```ruby
def resolved?
  source.present? && id.present?
end

def external?
  external == true
end

def ellipsis?
  ellipsis == true
end

def text_only?
  text.present? && !resolved? && !external?
end
```

### 3. Validation: mutual exclusivity

Add to `ConceptRef#validate!` (or a Validation::Rule):

```
REJECT if external: true AND (source present OR id present)
  → "external is mutually exclusive with source/id"

REJECT if ellipsis: true AND any other field present
  → "ellipsis is mutually exclusive with all other fields"

REJECT if none of (source+id, text, ellipsis) present
  → "ConceptRef must have (source,id), text, or ellipsis"
```

### 4. Serialization: HyperedgeWriter

When serializing a hyperedge to YAML, the writer must emit the new
fields. For `external: true` refs:

```yaml
# Writer output for external comprehensive:
comprehensive:
  text: "precision condition of measurement"
  external: true
```

For `ellipsis: true` members:
```yaml
members:
  - ref:
      ellipsis: true
```

### 5. HyperedgeMember / AbstractHyperedge helpers

```ruby
class AbstractHyperedge
  def has_external_members?
    members.any? { |m| m.ref.external? }
  end

  def has_ellipsis_member?
    members.any? { |m| m.ref.ellipsis? }
  end

  def external_members
    members.select { |m| m.ref.external? }
  end

  def ellipsis_members
    members.select { |m| m.ref.ellipsis? }
  end
end
```

### 6. Specs

```ruby
# spec/unit/v3/concept_ref_spec.rb
describe "external form" do
  it "constructs from {text: 'x', external: true}" do
    ref = ConceptRef.new(text: "precision condition", external: true)
    expect(ref).to be_external
    expect(ref).not_to be_resolved
  end

  it "rejects external + source together" do
    expect {
      ConceptRef.new(text: "x", external: true, source: "IEV", id: "1").validate!
    }.to raise_error(ArgumentError, /mutually exclusive/)
  end
end

describe "ellipsis form" do
  it "constructs from {ellipsis: true}" do
    ref = ConceptRef.new(ellipsis: true)
    expect(ref).to be_ellipsis
  end

  it "rejects ellipsis + any other field" do
    expect {
      ConceptRef.new(ellipsis: true, text: "x").validate!
    }.to raise_error(ArgumentError, /mutually exclusive/)
  end
end
```

---

## glossarist-js — what to do

### 1. ConceptRef class gains `external` and `ellipsis`

```javascript
// src/models/concept-ref.js
export class ConceptRef extends GlossaristModel {
  constructor(data = {}) {
    super();
    this.source = data.source ?? null;
    this.id = data.id ?? null;
    this.text = data.text ?? null;
    this.external = data.external ?? false;
    this.ellipsis = data.ellipsis ?? false;
  }

  get isResolved() { return this.source != null && this.id != null; }
  get isExternal() { return this.external === true; }
  get isEllipsis() { return this.ellipsis === true; }
  get isTextOnly() { return this.text != null && !this.isResolved && !this.isExternal; }

  toJSON() {
    if (this.ellipsis) return { ellipsis: true };
    const obj = {};
    if (this.source != null) obj.source = this.source;
    if (this.id != null) obj.id = this.id;
    if (this.text != null) obj.text = this.text;
    if (this.external) obj.external = true;
    return obj;
  }
}
```

### 2. Validation in HyperedgeMember construction

When constructing members, validate mutual exclusivity:

```javascript
function _validateConceptRef(ref) {
  if (ref.ellipsis && (ref.source || ref.id || ref.text || ref.external)) {
    throw new Error('ellipsis is mutually exclusive with all other ConceptRef fields');
  }
  if (ref.external && (ref.source || ref.id)) {
    throw new Error('external is mutually exclusive with source/id');
  }
  if (!ref.source && !ref.id && !ref.text && !ref.ellipsis) {
    throw new Error('ConceptRef must have (source,id), text, or ellipsis');
  }
}
```

### 3. Tests

```javascript
// test/models/concept-ref-external-ellipsis.test.js
test('ConceptRef external form', () => {
  const ref = new ConceptRef({ text: 'precision condition', external: true });
  assert.equal(ref.isExternal, true);
  assert.equal(ref.isResolved, false);
  assert.deepEqual(ref.toJSON(), { text: 'precision condition', external: true });
});

test('ConceptRef ellipsis form', () => {
  const ref = new ConceptRef({ ellipsis: true });
  assert.equal(ref.isEllipsis, true);
  assert.deepEqual(ref.toJSON(), { ellipsis: true });
});

test('ConceptRef rejects external + source', () => {
  assert.throws(
    () => new ConceptRef({ text: 'x', external: true, source: 'IEV', id: '1' }),
    /mutually exclusive/,
  );
});

test('ConceptRef rejects ellipsis + text', () => {
  assert.throws(
    () => new ConceptRef({ ellipsis: true, text: 'x' }),
    /mutually exclusive/,
  );
});
```

---

## concept-browser — what to do

### 1. External concept rendering

When a ConceptRef has `external: true`:

**In rake diagrams (PartitiveRelationDiagram.vue, etc.):**
- Member card: render designation in parentheses — `(precision condition of measurement)`
- Add a subtle dashed border on the card
- Add an "EXT" badge (small, muted color) in the card header
- If the concept store has a `provided_by` edge for this text: make the card clickable (links to the providing concept)
- If no `provided_by`: show a small warning icon with tooltip "External concept — definition not in this dataset"

**In comprehensive position:**
- Same parenthetical + dashed border + badge treatment
- The entire rake container gets a subtle dashed outline

**In binary relationship lists (RelatedConceptsList.vue):**
- External concept ref: show as `(text)` with dashed underline
- Regular concept ref: show as normal link

**Implementation:**

```vue
<!-- PartitiveRelationDiagram.vue -->
<script setup>
function memberDisplay(member) {
  const ref = member.ref;
  if (ref?.ellipsis) {
    return { text: '...', isEllipsis: true, isExternal: false };
  }
  if (ref?.external) {
    return {
      text: `(${ref.text})`,
      isEllipsis: false,
      isExternal: true,
    };
  }
  return {
    text: member.label || ref?.text || '',
    isEllipsis: false,
    isExternal: false,
  };
}
</script>

<template>
  <div v-for="m in members" :key="m.uri"
    class="member-card"
    :class="{
      'member-external': memberDisplay(m).isExternal,
      'member-ellipsis': memberDisplay(m).isEllipsis,
    }">
    <span v-if="memberDisplay(m).isExternal" class="ext-badge">EXT</span>
    <span class="label">{{ memberDisplay(m).text }}</span>
  </div>
</template>

<style scoped>
.member-external {
  border: 1px dashed var(--color-border);
  font-style: italic;
}

.member-ellipsis {
  color: var(--color-text-muted);
  border: none;
  font-weight: normal;
}

.ext-badge {
  font-size: 0.6rem;
  background: var(--color-warn-soft);
  color: var(--color-warn-fg);
  padding: 0.05rem 0.3rem;
  border-radius: 3px;
  text-transform: uppercase;
}
</style>
```

### 2. Ellipsis rendering

When a ConceptRef has `ellipsis: true`:

**In rake diagrams:**
- Render a small "..." element (muted color, no border) at the member position
- The backline should pass through it normally (it's a tooth position, just unnamed)

**In sequential hyperedge arrow diagrams:**
- Render "..." between two known members: `step-1 → ... → step-5`
- Arrow notation continues through the ellipsis

**In binary relationship lists:**
- Show as "..." with a tooltip "Author indicated a target exists but hasn't identified it"

### 3. Resolution behavior

External concepts (`external: true`) and ellipsis (`ellipsis: true`) do NOT resolve via the concept store — they are intentionally unresolved. The renderer should:

| ConceptRef form | Resolution attempt | Render |
|---|---|---|
| `{source, id}` | Look up in concept store | Resolved link or "unresolved" indicator |
| `{text, external: true}` | **No lookup** — display only | `(text)` with EXT badge |
| `{ellipsis: true}` | **No lookup** — display only | `...` |

### 4. Tests

```typescript
// src/__tests__/components/ExternalConceptRendering.test.ts
test('external concept renders with parentheses', () => {
  const member = {
    ref: { text: 'precision condition', external: true },
    presence: 'required',
    count: 'exactly_one',
  };
  const display = memberDisplay(member);
  expect(display.text).toBe('(precision condition)');
  expect(display.isExternal).toBe(true);
});

test('ellipsis renders as ...', () => {
  const member = {
    ref: { ellipsis: true },
    presence: 'required',
    count: 'exactly_one',
  };
  const display = memberDisplay(member);
  expect(display.text).toBe('...');
  expect(display.isEllipsis).toBe(true);
});
```

---

## French translations (for OIML V 2-200:2012)

The canonical English → French translation table for external
concepts in this dataset is at:

```
~/src/oimlsmart/vocab/reference-docs/oiml-v2-200-2012-external-concept-translations.md
```

When rendering external concepts (`external: true`) in a French
localization context, the adapter should look up the `text` in this
table to find the French equivalent. 27 entries covering all
parenthetical concepts in the OIML V 2-200:2012 diagrams.

---

## Summary checklist

### glossarist-ruby
- [ ] ConceptRef gains `external` + `ellipsis` attributes
- [ ] Predicates: `resolved?`, `external?`, `ellipsis?`, `text_only?`
- [ ] Validation: mutual exclusivity (external vs source/id; ellipsis vs all)
- [ ] HyperedgeWriter emits new fields
- [ ] AbstractHyperedge helpers: `has_external_members?`, `has_ellipsis_member?`
- [ ] Specs for all five forms + rejection cases

### glossarist-js
- [ ] ConceptRef constructor accepts `external` + `ellipsis`
- [ ] Predicates: `isResolved`, `isExternal`, `isEllipsis`, `isTextOnly`
- [ ] `toJSON()` emits minimal shape per form
- [ ] Validation in member construction
- [ ] Tests for all five forms + rejection cases

### concept-browser
- [ ] `memberDisplay()` helper: detects external → parens, ellipsis → `...`
- [ ] External member card: dashed border + `(text)` + EXT badge
- [ ] Ellipsis member: muted `...` element at position
- [ ] External comprehensive: dashed rake container outline
- [ ] No resolution attempt for external/ellipsis refs
- [ ] Binary relationship list: external → `(text)`, ellipsis → `...`
- [ ] Tests for both rendering paths
