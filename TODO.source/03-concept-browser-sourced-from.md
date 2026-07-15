# 03 — concept-browser: Display `sourced_from` on sources

## Context

The concept-model now defines `sourced_from` on `ConceptSource` as an array of
`Citation` objects. The concept-browser needs to:
1. Pass `sourced_from` through the data bridge (JSON-LD → native format)
2. Render `sourced_from` citations alongside each source's `origin`

## Changes

### 1. TypeScript augmentation: `src/adapters/non-verbal/glossarist-augment.d.ts`

Add `sourced_from` to the `ConceptSource` class via module augmentation:

```ts
declare module 'glossarist' {
  interface ConceptSource {
    sourced_from?: Citation[];
  }
}
```

### 2. JSON-LD bridge: `src/adapters/model-bridge.ts`

- `JsonLdSource` interface (line ~100): add `'gl:sourced_from'?: JsonLdOrigin[]`
- `mapSourceFromJsonLd()` (line ~411): map `'gl:sourced_from'` to
  `sourced_from` in the native format, converting each entry through the same
  origin-mapping logic used for `origin`.

### 3. Non-verbal bridge: `src/adapters/non-verbal/`

- `types.ts`: add `sourced_from?: NonVerbalSourceOrigin[]` to `NonVerbalSource`
- `source-bridge.ts`: parse `sourced_from` in `sourceFromJsonLd()`

### 4. Rendering — add `sourced_from` display after origin CitationDisplay

Each source rendering location gets a "sourced from" subsection listing the
upstream citations via the existing `CitationDisplay` component.

**Files to update:**

- `src/components/ConceptDetail.vue` — per-language sources (line ~439-452) and
  concept-level sources (line ~604-619)
- `src/components/DesignationList.vue` — designation sources (line ~59-64)
- `src/components/NonVerbalRepDisplay.vue` — non-verbal rep sources (line ~61-66)
- `src/components/non-verbal/NonVerbalSources.vue` — shared non-verbal sources
- `src/components/LanguageDetail.vue` — standalone language page sources (line ~167-181)

**Render pattern:**

```vue
<div v-if="src.sourced_from?.length" class="text-xs text-ink-400 mt-1">
  <span class="text-ink-300">{{ t('concept.sourcedFrom') }}:</span>
  <div v-for="(sf, sfi) in src.sourced_from" :key="'sf'+sfi" class="ml-2">
    <CitationDisplay v-if="sf" :citation="sf" :register-id="registerId" />
  </div>
</div>
```

### 5. i18n strings

Add `concept.sourcedFrom` translation key ("Sourced from" in English) to the
locale files.

### 6. Test fixtures

- `src/__tests__/__fixtures__/concepts.ts`: add `sourced_from` to the
  `withSources()` fixture
- Any RDF conformance test fixtures that include sources

## Validation

```sh
cd /Users/mulgogi/src/glossarist/concept-browser
npm run build
npm test
```
