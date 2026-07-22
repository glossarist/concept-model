# 02 — P0: Publish the design doc

## Problem

- `.gitignore` excludes `TODO.hyperedge/`.
- `README.adoc:153` references `TODO.hyperedge/00-design-overview.md`.
- `CHANGELOG.md:17` references the same file.
- The contributor's `TODO.hyperedges/37-P2-concept-model-extraction-trigger.md`
  appended the extraction-trigger documentation to that file — also
  gitignored.

Result: published docs link to files that don't exist on disk for any
consumer reading the published repo.

The contributor's own `glossarist-ruby/TODO.hyperedges/34-P2-concept-model-todo-gitignore.md`
explicitly acknowledged that `TODO.hyperedge/` "is part of the
documented design rationale" — then proceeded to gitignore it anyway,
without moving the file. Worst of both worlds.

## Fix

1. Move `TODO.hyperedge/00-design-overview.md` to
   `docs/design/partitive-hyperedge.md` (committed, navigable from
   GitHub).
2. Update `README.adoc:153` and `CHANGELOG.md:17` to point at the
   new location.
3. The extraction-trigger section from `TODO.hyperedges/37-P2-...`
   lands in the same published file.

## Verification

```bash
test -f docs/design/partitive-hyperedge.md
grep -r "TODO.hyperedge" README.adoc CHANGELOG.md && echo "BROKEN REFS" || echo "OK"
```

## Status: pending
