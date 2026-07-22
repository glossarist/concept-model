#!/usr/bin/env bash
# Cross-repo integration: every example YAML must round-trip through
# every consumer's parser/serializer without loss.
#
# Invoked manually or from a release-preflight workflow. Assumes the
# sibling repos (glossarist-ruby, glossarist-js, concept-browser) are
# checked out next to concept-model. Override locations with
# GLOSSARIST_RUBY, GLOSSARIST_JS, CONCEPT_BROWSER env vars.

set -euo pipefail

CONCEPT_MODEL="$(cd "$(dirname "$0")/.." && pwd)"

RUBY="${GLOSSARIST_RUBY:-../glossarist-ruby}"
JS="${GLOSSARIST_JS:-../glossarist-js}"
BROWSER="${CONCEPT_BROWSER:-../concept-browser}"

fail=0

echo "== concept-model: validate examples against schema =="
( cd "$CONCEPT_MODEL" && python3 scripts/validate-examples.py ) || fail=1

echo "== concept-model: check enum drift =="
( cd "$CONCEPT_MODEL" && python3 scripts/check-enum-drift.py ) || fail=1

echo "== concept-model: validate ontologies =="
( cd "$CONCEPT_MODEL" && python3 scripts/validate-ontologies.py >/dev/null ) || fail=1

if [ -d "$RUBY" ]; then
  echo "== glossarist-ruby: hyperedge integration spec =="
  ( cd "$RUBY" && bundle exec rspec spec/unit/integration/cross_repo_hyperedge_spec.rb ) || fail=1
else
  echo "skip glossarist-ruby (not found at $RUBY)"
fi

if [ -d "$JS" ]; then
  echo "== glossarist-js: hyperedge round-trip test =="
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

if [ "$fail" -eq 0 ]; then
  echo "OK: all integration checks passed"
else
  echo "FAIL: one or more integration checks failed"
fi
exit $fail
