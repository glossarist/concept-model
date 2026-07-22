# 07 — P1: `scripts/check-lutaml-references.py`

## Problem

LUTAML model files reference each other by class name (e.g.
`ManagedConcept` references `RelatedConcept`). If a model is
renamed or deleted, the references break silently. There's no
check.

## Fix

Create `scripts/check-lutaml-references.py`:

```python
#!/usr/bin/env python3
"""Verify every class referenced in a LUTAML model file exists.

For each model file under models/, parse class references like
`+field: ClassName [cardinality]` and verify that `ClassName`
is defined somewhere in models/.

Excludes well-known external types: LocalizedString,
ReferenceToTermbase, ParagraphBlock, TextElement, etc.

Exits 0 on success, non-zero on any unresolved reference.
"""
import re, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
MODELS_DIR = REPO / "models"

EXTERNAL_TYPES = {
    "LocalizedString", "ReferenceToTermbase", "ParagraphBlock",
    "TextElement", "TextElementType",
}

REF_RE = re.compile(
    r"^\s*\+\w+:\s+(?:<<\w+>>\s+)?([A-Z][A-Za-z0-9_]*)\b",
    re.MULTILINE,
)


def model_class_names():
    names = set()
    for path in MODELS_DIR.rglob("*.lutaml"):
        names.add(path.stem)
    return names


def find_references(path):
    refs = set()
    for m in REF_RE.finditer(path.read_text()):
        refs.add(m.group(1))
    return refs


def main():
    defined = model_class_names() | EXTERNAL_TYPES
    broken = []
    for path in sorted(MODELS_DIR.rglob("*.lutaml")):
        for ref in find_references(path):
            if ref not in defined:
                broken.append((path.name, ref))
    if broken:
        print(f"FAIL: {len(broken)} unresolved LUTAML references:", file=sys.stderr)
        for f, r in sorted(broken):
            print(f"  {f}: → {r}", file=sys.stderr)
        sys.exit(1)
    print(f"OK: all LUTAML references resolve")


if __name__ == "__main__":
    main()
```

## Verification

```bash
python scripts/check-lutaml-references.py
```

## Status: pending
