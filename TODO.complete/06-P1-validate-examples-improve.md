# 06 — P1: Improve `validate-examples.py`

## Problems

The current `scripts/validate-examples.py` has three issues:

### a) Validates every example against `concept.yaml`
Many examples are localized concepts (`01-minimal-localized.yaml`,
`02-designation-*.yaml`, etc.) that should validate against
`localized-concept.yaml`. They mostly pass anyway because
`concept.yaml` has no top-level `required` or
`additionalProperties: false`. The validator is weaker than it
looks — it's only catching nested type errors.

### b) Docstring promises a `--report-all` flag that doesn't exist
Line 8: *"Exits 0 on success, non-zero on first failure (or counts
failures and exits non-zero at end if --report-all)."* The current
implementation always collects all failures and exits non-zero at
end. The docstring lies about the default behavior.

### c) Schema parse repeated per example
Minor — the schema is loaded once. (Already correct. Leaving for
audit completeness.)

## Fix

### a) Schema-per-file
Map filename pattern to schema:

```python
SCHEMAS = {
    "managed": REPO_ROOT / "schemas/v3/concept.yaml",
    "localized": REPO_ROOT / "schemas/v3/localized-concept.yaml",
}

def schema_for(path: Path):
    name = path.name
    if "localized" in name or "designation" in name or "pronunciation" in name \
       or "term-types" in name or "citation-features" in name \
       or "nonverbal" in name or "multilanguage-" in name \
       or "minimal-localized" in name or name.startswith("0") and "minimal" in name:
        return "localized"
    # Multi-doc files: first doc is managed, others are localized.
    return "managed"
```

Actually a cleaner rule: parse all docs; doc 0 is managed; docs 1..N
are localized. Apply the right schema per document.

### b) Report flag
Either remove the `--report-all` mention from the docstring, or
implement it:

```python
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--report-all", action="store_true",
                    help="Continue after first failure (default: on)")
args = parser.parse_args()
```

Since the script already collects all failures, make `--report-all`
the default and remove the flag, or keep it as a no-op alias for
backward compatibility.

## Verification

```bash
python scripts/validate-examples.py
# Expected: 0 failures (after item 07 fixes the status:current bugs)
```

## Status: pending
