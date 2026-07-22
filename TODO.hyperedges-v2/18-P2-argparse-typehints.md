# 18 — P2: `argparse` + type hints for Python scripts

## Problem

The three validation scripts use bare `print` and `sys.exit`. No
`--help`, no `--verbose`, no type annotations. Minor DX issue.

## Fix

For each script, wrap `main()` in `argparse` and add type hints:

```python
import argparse
from typing import Iterable


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate YAML examples against JSON Schema.",
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true",
        help="Print one line per validated file.",
    )
    parser.add_argument(
        "--examples-dir", type=Path,
        default=REPO_ROOT / "schemas/v3/examples",
        help="Override examples directory.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    # ...
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
```

## Apply to

- `scripts/validate-examples.py`
- `scripts/check-enum-drift.py`
- `scripts/validate-ontologies.py`
- `scripts/check-jsonld-context.py`
- `scripts/check-shacl-coverage.py`
- `scripts/check-lutaml-references.py`

## Verification

```bash
python scripts/validate-examples.py --help
python scripts/validate-examples.py --verbose
```

## Out of scope for this PR

Cosmetic improvement. Land alongside item 08 (script test suite).

## Status: pending (P2)
