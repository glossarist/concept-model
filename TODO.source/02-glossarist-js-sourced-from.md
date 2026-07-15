# 02 — glossarist-js: Add `sourced_from` to ConceptSource

## Context

The concept-model now defines `sourced_from` on `ConceptSource` as an array of
`Citation` objects. The JS implementation needs to parse, store, and serialize
this field.

## Changes

### 1. Model: `src/models/concept-source.js`

Add `sourced_from` to the constructor (eager array pattern, like
`Designation.sources`):

```js
this.sourced_from = (data.sourced_from ?? []).map(
  c => c instanceof Citation ? c : new Citation(c)
);
```

Add to `toJSON()`:

```js
if (this.sourced_from.length > 0) obj.sourced_from = this.sourced_from.map(c => c.toJSON());
```

### 2. TypeScript types: `src/models/index.d.ts`

Add `sourced_from` to the `ConceptSource` class declaration:

```ts
export class ConceptSource extends GlossaristModel {
  readonly status: string | null;
  readonly type: string | null;
  readonly origin: Citation | null;
  readonly modification: string | null;
  readonly sourced_from: Citation[];
}
```

### 3. RDF emitter: `src/rdf/gloss-source.js`

Emit `gloss:sourcedFrom` quads for each `sourced_from` Citation, using the same
pattern as `sourceOrigin` (lines 29-51). Each `sourced_from` Citation is emitted
as a blank node with `gloss:hasCitationRef`, `gloss:hasCitationLocality`, etc.

### 4. Predicates: `src/rdf/predicates.js`

Add the `sourcedFrom` predicate entry (already exists in the JSON-LD context as
`gloss:sourcedFrom`):

```js
sourcedFrom: 'https://www.glossarist.org/ontologies/sourcedFrom',
```

### 5. Tests: `test/models/concept-source.test.js`

Add tests for:
- `sourced_from` defaults to empty array
- `sourced_from` wraps plain objects as Citation instances
- `sourced_from` round-trips through toJSON/fromJSON
- `sourced_from` with multiple citations

### 6. RDF tests: `test/rdf/gloss-source.test.js`

Add test for `sourced_from` RDF emission.

## Validation

```sh
cd /Users/mulgogi/src/glossarist/glossarist-js
npm test
npm run lint
```
