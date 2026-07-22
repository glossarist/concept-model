# 03 — P0: Fix README version claim

## Problem

`README.adoc:126` says:

> glossarist v3.1 introduces `PartitiveHyperedge` for *one-to-many*
> partitive decompositions

But `v3.1.0` shipped 2026-07-05 **without** this feature — it's in
`[Unreleased]` (CHANGELOG.md:12). Claiming v3.1 introduces it is
historically wrong and will mislead consumers checking release
notes.

## Fix

Replace "glossarist v3.1 introduces" with one of:
- "glossarist's `[Unreleased]` work introduces"
- "the upcoming release introduces"
- "glossarist introduces" (drop version)

Recommended: "the upcoming release introduces" — accurate, doesn't
pre-commit a version number.

## Verification

```bash
grep -n "v3\.1 introduces\|v3\.2 introduces" README.adoc && echo "BROKEN" || echo "OK"
```

## Status: pending
