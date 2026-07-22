# 14 — P1: Cross-repo integration script

## Problem

The contributor's `glossarist-ruby/TODO.hyperedges/44-cross-repo-integration-test.md`
claims "Status: ✅ Done" for a `scripts/integration.sh` that
"downloads the latest fixtures and runs each repo's integration spec."

**The script does not exist.** Verified:

```bash
$ ls scripts/integration.sh
ls: scripts/integration.sh: No such file or directory
```

## Scope

This script lives in `concept-model` because it consumes
`schemas/v3/examples/*.yaml` and exercises each downstream repo's
parser/serializer against them.

## Fix

### Stub (cannot be fully implemented here)

`scripts/integration.sh`:

```bash
#!/usr/bin/env bash
# Cross-repo integration: every example YAML must round-trip through
# every consumer's parser/serializer without loss.
#
# This script is invoked manually or from a release-preflight workflow.
# It assumes the sibling repos (glossarist-ruby, glossarist-js,
# concept-browser) are checked out next to concept-model.

set -euo pipefail

CONCEPT_MODEL="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLES="$CONCEPT_MODEL/schemas/v3/examples"

RUBY="${GLOSSARIST_RUBY:-../glossarist-ruby}"
JS="${GLOSSARIST_JS:-../glossarist-js}"
BROWSER="${CONCEPT_BROWSER:-../concept-browser}"

fail=0

echo "== concept-model: validate examples against schema =="
( cd "$CONCEPT_MODEL" && python scripts/validate-examples.py ) || fail=1

echo "== concept-model: check enum drift =="
( cd "$CONCEPT_MODEL" && python scripts/check-enum-drift.py ) || fail=1

if [ -d "$RUBY" ]; then
  echo "== glossarist-ruby: hyperedge integration spec =="
  ( cd "$RUBY" && bundle exec rspec spec/unit/integration/cross_repo_hyperedge_spec.rb ) || fail=1
else
  echo "skip glossarist-ruby (not found at $RUBY)"
fi

if [ -d "$JS" ]; then
  echo "== glossarist-js: hyperedge integration test =="
  ( cd "$JS" && node --test test/integration/hyperedge-roundtrip.test.js ) || fail=1
else
  echo "skip glossarist-js (not found at $JS)"
fi

if [ -d "$BROWSER" ]; then
  echo "== concept-browser: hyperedge data pipeline test =="
  ( cd "$BROWSER" && npx vitest run src/__tests__/partitive-hyperedge.test.ts ) || fail=1
else
  echo "skip concept-browser (not found at $BROWSER)"
fi

exit $fail
```

### CI wiring (deferred)

Cross-repo CI requires either:
- git submodules (heavy)
- A separate meta-repo that depends on all four (preferred)
- Or a scheduled job that pulls latest tags of each repo

Out of scope for this PR. Document the script's manual use in
`RELEASE_PROCESS.md`.

## Verification

```bash
chmod +x scripts/integration.sh
./scripts/integration.sh
```

## Status: pending
