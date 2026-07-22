# 06 — P1: `scripts/check-shacl-coverage.py`

## Problem

Every `owl:Class` in the ontology should have a corresponding
`sh:NodeShape` declaring its property constraints. Today only 32
of 43 classes are shaped. Item 02 fixes the 5 real gaps; this
script prevents the next gap.

## Fix

Create `scripts/check-shacl-coverage.py`:

```python
#!/usr/bin/env python3
"""Cross-check ontology classes vs SHACL NodeShapes.

For every owl:Class in ontologies/glossarist.ttl, there must be a
sh:NodeShape in ontologies/shapes/glossarist.shacl.ttl with
sh:targetClass pointing at it. Blank-node union classes are
excluded.

Exits 0 on success, non-zero on any unshaped class.
"""
import sys
from pathlib import Path
from rdflib import Graph, Namespace, RDF
from rdflib.namespace import OWL

REPO = Path(__file__).resolve().parents[1]
ONTOLOGY = REPO / "ontologies" / "glossarist.ttl"
SHACL_FILE = REPO / "ontologies" / "shapes" / "glossarist.shacl.ttl"
SHACL = Namespace("http://www.w3.org/ns/shacl#")
GLOSS = Namespace("https://www.glossarist.org/ontologies/")


def ontology_classes():
    g = Graph(); g.parse(ONTOLOGY, format="turtle")
    out = set()
    for s in g.subjects(RDF.type, OWL.Class):
        if str(s).startswith(str(GLOSS)):
            out.add(str(s).rsplit("/", 1)[-1])
    return out


def shaped_classes():
    g = Graph(); g.parse(SHACL_FILE, format="turtle")
    return set(str(o).rsplit("/", 1)[-1] for o in g.objects(None, SHACL.targetClass))


def main():
    onto = ontology_classes()
    shaped = shaped_classes()
    unshaped = onto - shaped
    if unshaped:
        print(f"FAIL: {len(unshaped)} ontology classes have no SHACL shape:",
              file=sys.stderr)
        for u in sorted(unshaped):
            print(f"  - gloss:{u}", file=sys.stderr)
        sys.exit(1)
    print(f"OK: all {len(onto)} ontology classes have SHACL shapes")


if __name__ == "__main__":
    main()
```

## Wire into CI

Add job to `.github/workflows/validate-schemas.yml`.

## Verification

After item 02 adds the missing shapes:

```bash
python scripts/check-shacl-coverage.py
# Expected: OK: all N ontology classes have SHACL shapes
```

## Status: pending
