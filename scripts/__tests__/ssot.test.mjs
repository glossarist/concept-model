/**
 * Tests for the concept-model SSOT layer.
 *
 * Verifies:
 * - Codegen output is present and parseable
 * - Prefix discipline: skosxl:, never xl:
 * - SHACL shapes file references only declared prefixes
 * - JSON-LD context and ontology are mutually consistent on namespace URIs
 *
 * Run: `node --test scripts/__tests__/ssot.test.mjs`
 */
import { describe, it } from 'node:test';
import { ok, strictEqual, deepStrictEqual } from 'node:assert';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const read = (rel) => readFileSync(resolve(ROOT, rel), 'utf8');

describe('concept-model SSOT', () => {
  describe('prefix discipline', () => {
    it('uses skosxl: for SKOS-XL in glossarist.ttl', () => {
      const ttl = read('ontologies/glossarist.ttl');
      ok(ttl.includes('@prefix skosxl:'), 'glossarist.ttl must declare @prefix skosxl:');
      ok(!/^@prefix xl:/m.test(ttl), 'glossarist.ttl must not declare @prefix xl:');
    });

    it('uses skosxl: for SKOS-XL in SHACL shapes', () => {
      const ttl = read('ontologies/shapes/glossarist.shacl.ttl');
      ok(ttl.includes('@prefix skosxl:'), 'shacl.ttl must declare @prefix skosxl:');
      ok(!/^@prefix xl:/m.test(ttl), 'shacl.ttl must not declare @prefix xl:');
    });

    it('uses skosxl: for SKOS-XL in JSON-LD context', () => {
      const ctx = JSON.parse(read('ontologies/glossarist.context.jsonld'));
      deepStrictEqual(ctx['@context'].skosxl, 'http://www.w3.org/2008/05/skos-xl#',
        'JSON-LD context must map skosxl: to the canonical URI');
      ok(!('xl' in ctx['@context']), 'JSON-LD context must not map xl:');
    });
  });

  describe('prefixes.ttl SSOT', () => {
    it('exists and declares the canonical namespaces', () => {
      const ttl = read('ontologies/prefixes.ttl');
      for (const p of ['gloss:', 'skos:', 'skosxl:', 'iso-thes:', 'dcterms:', 'prov:']) {
        ok(ttl.includes(`@prefix ${p}`), `prefixes.ttl must declare ${p}`);
      }
      ok(!/@prefix xl:/m.test(ttl), 'prefixes.ttl must not declare xl:');
    });
  });

  describe('codegen output', () => {
    it('emits TypeScript predicates module', () => {
      const ts = read('dist/js/predicates.d.ts');
      ok(ts.includes('export const PRED'), 'predicates.d.ts must export PRED');
      ok(ts.includes('"https://www.glossarist.org/ontologies/Concept"'),
        'predicates.d.ts must include gloss:Concept URI');
      ok(ts.includes('"http://www.w3.org/2008/05/skos-xl#literalForm"'),
        'predicates.d.ts must include skosxl:literalForm URI');
      ok(ts.includes('export type Predicate'), 'predicates.d.ts must export Predicate type');
      ok(ts.includes('export const PREFIXES'), 'predicates.d.ts must export PREFIXES map');
    });

    it('emits Ruby predicates module', () => {
      const rb = read('dist/ruby/lib/glossarist/concept_model/predicates.rb');
      ok(rb.includes('module Glossarist'), 'predicates.rb must define Glossarist module');
      ok(rb.includes('module ConceptModel'), 'predicates.rb must define ConceptModel module');
      ok(rb.includes('"https://www.glossarist.org/ontologies/Concept"'),
        'predicates.rb must include gloss:Concept URI');
    });

    it('TS and Ruby outputs agree on gloss:Concept URI', () => {
      const ts = read('dist/js/predicates.d.ts');
      const rb = read('dist/ruby/lib/glossarist/concept_model/predicates.rb');
      const tsHas = /"https:\/\/www\.glossarist\.org\/ontologies\/Concept"/.test(ts);
      const rbHas = /"https:\/\/www\.glossarist\.org\/ontologies\/Concept"/.test(rb);
      strictEqual(tsHas, true, 'TS missing gloss:Concept');
      strictEqual(rbHas, true, 'Ruby missing gloss:Concept');
    });
  });

  describe('JSON-LD context — ontology sync', () => {
    it('every namespace in the context is consistent with prefixes.ttl', () => {
      const ctx = JSON.parse(read('ontologies/glossarist.context.jsonld'))['@context'];
      const prefixesTtl = read('ontologies/prefixes.ttl');

      for (const [prefix, uri] of Object.entries(ctx)) {
        if (typeof uri !== 'string') continue;
        if (!uri.endsWith('/') && !uri.endsWith('#')) continue;       // skip term-valued strings
        // Match `@prefix <prefix>: <uri>` with any whitespace
        const decl = new RegExp(`^@prefix\\s+${prefix}:\\s+<${uri.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}>`, 'm');
        ok(decl.test(prefixesTtl),
          `prefixes.ttl missing declaration for "${prefix}: <${uri}>"`);
      }
    });
  });
});
