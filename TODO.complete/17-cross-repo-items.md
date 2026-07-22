# 17 — Cross-repo items (out of scope for this repo)

These items are claimed "✅ Done" in
`glossarist-ruby/TODO.hyperedges/45-summary.md` but live in other
repos. Listed here for visibility — execute in the respective repos,
not from concept-model.

## glossarist-ruby

### Verified-elsewhere claims
- `lib/glossarist/v3/partitive_hyperedge.rb` — rewritten with
  `validate!`, no hand-rolled setters (TODO 01)
- `lib/glossarist/v3/managed_concept.rb` — `partitive_hyperedges`
  at concept level, not data (TODO 09)
- `GlossaryDefinition` SSOT loaded from `config.yml` (TODO 02)
- `PartitiveHyperedgeRule` validator (TODO 03)
- RDF emission via `GlossHyperedge` (TODO 04)
- V2→V3 migration explicit no-op (TODO 05)
- `detect_schema_version` includes hyperedges (TODO 06)
- 23 spec examples (TODO 07)
- CLAUDE.md section (TODO 08)

### To verify in glossarist-ruby
- [ ] `bundle exec rspec` passes
- [ ] `bundle exec rspec spec/unit/integration/cross_repo_hyperedge_spec.rb`
      uses the fixture from concept-model (cross-repo link works)
- [ ] No `send` to private methods
- [ ] No `instance_variable_set/get`
- [ ] No `respond_to?` for type checks
- [ ] No `require_relative` for internal library code (autoload only)
- [ ] No doubles in specs (real model instances)
- [ ] No hand-rolled serialization (lutaml-model only)

## glossarist-js

### Verified-elsewhere claims
- `src/models/partitive-hyperedge.js` rewritten (TODO 10-25)
- Parser/serializer/diff/resolver/validator integration
- `makeEnum` factory
- TypeScript declarations
- 20 tests

### To verify in glossarist-js
- [ ] `npm test` passes (1096 tests claimed)
- [ ] Invalid markers throw (not filter)
- [ ] Comprehensive + parts validated at construction
- [ ] `content` is a localized string hash
- [ ] Markers dedup with throw on duplicate
- [ ] `resolveHyperedgeColor` resolver
- [ ] Reconciliation with `relation-categories` and `relation-colors`

## concept-browser

### Verified-elsewhere claims
- Data pipeline emits `hyperedges.json` (TODO 38)
- `PartitiveHyperedgeList.vue` renders (TODO 39)
- Stats include hyperedge counts (TODO 40)
- Specs cover pipeline (TODO 41)
- `scripts/migrate-vocab-data.mjs` (TODO 42)
- `site-config.example.yml` migration contract (TODO 43)

### To verify in concept-browser
- [ ] `npm test` passes (1081 claimed)
- [ ] PartitiveHyperedgeList is wired into ConceptDetail (currently
      deferred per contributor's TODO.hyperedge/10)
- [ ] GraphPanel rake rendering (deferred)

## vocab datasets

### Migration status
- vim-2007: 10 hyperedges (per TODO.hyperedge/13)
- vim-2010: 9 hyperedges
- vim-2012: 13 hyperedges

### To verify
- [ ] `ruby scripts/validate_datasets.rb --datasets vim-2007,vim-2010,vim-2012`
      passes (per TODO.hyperedge/15)
- [ ] Site build succeeds (per TODO.hyperedge/15)
- [ ] After concept-browser release, UI rendering verified in
      `npm run preview`

## Cross-repo integration

- [ ] `concept-model/scripts/integration.sh` (item 14) — when
      implemented, runs all four repo test suites against the same
      fixtures.

## Release coordination

When all four repos are green:
1. Tag concept-model `vX.Y.Z` (per `RELEASE_PROCESS.md`).
2. Bump glossarist-ruby pinned concept-model tag.
3. Bump glossarist-js pinned concept-model tag.
4. Release glossarist-ruby gem, glossarist-js npm package.
5. Bump concept-browser deps; release concept-browser npm package.
6. Bump vocab datasets' concept-browser dep; rebuild sites.

## Status: tracking only — execute in respective repos
