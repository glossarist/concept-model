# 08 — P1: pytest suite for the validation scripts

## Problem

The three validation scripts (`validate-examples.py`,
`check-enum-drift.py`, `validate-ontologies.py`) have no tests.
They could regress silently. A bug in the drift checker that
approves drift is worse than no drift checker.

## Fix

Create `scripts/tests/` and add `pytest` tests:

```
scripts/
  tests/
    __init__.py
    conftest.py
    test_validate_examples.py
    test_check_enum_drift.py
    test_validate_ontologies.py
    test_check_jsonld_context.py
    test_check_shacl_coverage.py
    fixtures/
      valid_example.yaml
      invalid_example_missing_required.yaml
      invalid_example_unknown_enum.yaml
      drift_schema.yaml
      ...
```

### Example test (test_validate_examples.py)

```python
"""Tests for scripts/validate-examples.py."""
import subprocess, sys, textwrap
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]


def run_validator(cwd):
    result = subprocess.run(
        [sys.executable, "scripts/validate-examples.py"],
        cwd=cwd, capture_output=True, text=True,
    )
    return result.returncode, result.stdout, result.stderr


def test_passes_on_current_repo():
    rc, out, err = run_validator(REPO)
    assert rc == 0, f"expected pass, got rc={rc}\nstderr={err}"
    assert "OK" in out


def test_detects_invalid_enum(tmp_path):
    # Symlink the schemas/ dir, then drop a bad example.
    (tmp_path / "schemas").mkdir()
    # ... construct minimal broken example ...
    rc, out, err = run_validator(tmp_path)
    assert rc != 0
    assert "FAIL" in err
```

### Run

```bash
pip install pytest
pytest scripts/tests/
```

## Wire into CI

Add job to `.github/workflows/validate-schemas.yml`:

```yaml
  script-tests:
    name: Validation script unit tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install pytest jsonschema pyyaml rdflib
      - run: pytest scripts/tests/ -v
```

## Verification

```bash
pytest scripts/tests/ -v
```

## Status: pending
