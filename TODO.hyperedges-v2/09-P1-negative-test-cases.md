# 09 — P1: Curated negative test cases

## Problem

The example suite only contains valid YAML. The schema is never
exercised against deliberately broken inputs — so we don't know
which constraints actually fire. A regression that loosens the
schema (e.g. removing `minItems: 1` from `parts`) is invisible.

## Fix

Create `schemas/v3/examples/_negative/` (underscore prefix =
excluded from the default validate-examples glob) with curated
broken cases:

```
schemas/v3/examples/_negative/
  README.md
  01-missing-required-comprehensive.yaml
  02-empty-parts.yaml
  03-invalid-enumeration-value.yaml
  04-invalid-marker.yaml
  05-self-loop-comprehensive-in-parts.yaml
  06-duplicate-markers.yaml
  07-unknown-field-on-hyperedge.yaml
  08-unknown-field-on-concept.yaml
  09-status-not-in-enum.yaml
  10-related-type-not-in-enum.yaml
```

Each file has a header comment explaining what it tests.

### Test runner

Add a script `scripts/validate-negative-examples.py`:

```python
#!/usr/bin/env python3
"""Validate that every negative example FAILS validation.

If a negative example passes, the schema has been loosened too far.
"""
import yaml, jsonschema, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
NEG_DIR = REPO / "schemas/v3/examples/_negative"

def main():
    failures = []
    for path in sorted(NEG_DIR.glob("*.yaml")):
        doc = yaml.safe_load(path.read_text())
        # Try the appropriate schema based on filename/content
        schema_path = REPO / "schemas/v3/concept.yaml"
        schema = yaml.safe_load(schema_path.read_text())
        try:
            jsonschema.validate(doc, schema)
            failures.append((path.name, "expected to FAIL but passed"))
        except jsonschema.ValidationError:
            pass  # correct behavior
    if failures:
        for name, msg in failures:
            print(f"FAIL: {name}: {msg}", file=sys.stderr)
        sys.exit(1)
    print(f"OK: all {len(list(NEG_DIR.glob('*.yaml')))} negative examples correctly rejected")
```

### Wire into CI

Add to `.github/workflows/validate-schemas.yml`.

## Verification

```bash
python scripts/validate-negative-examples.py
```

After item 03 (additionalProperties: false), some negative tests
that previously passed will start failing — that's the schema
catching more bugs. Update tests accordingly.

## Status: pending
