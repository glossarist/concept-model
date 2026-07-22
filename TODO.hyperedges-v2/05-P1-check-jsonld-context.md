# 05 — P1: `scripts/check-jsonld-context.py`

## Problem

The JSON-LD context file is hand-curated. Adding a new ontology
property requires manually adding the context entry. Forgetting
silently breaks RDF consumers.

Item 01 in this plan catches the current 4 missing entries. This
script prevents the next 4.

## Fix

Create `scripts/check-jsonld-context.py`:

```python
#!/usr/bin/env python3
"""Cross-check ontology properties vs JSON-LD context entries.

For every owl:ObjectProperty and owl:DatatypeProperty in
ontologies/glossarist.ttl, the JSON-LD context at
ontologies/glossarist.context.jsonld must contain a term that maps
to it. Reports any property missing from the context.

Exits 0 on success, non-zero on any missing term.
"""
import json, sys
from pathlib import Path
from rdflib import Graph, Namespace, RDF
from rdflib.namespace import OWL

REPO = Path(__file__).resolve().parents[1]
ONTOLOGY = REPO / "ontologies" / "glossarist.ttl"
CONTEXT = REPO / "ontologies" / "glossarist.context.jsonld"
GLOSS = Namespace("https://www.glossarist.org/ontologies/")


def ontology_property_names():
    g = Graph(); g.parse(ONTOLOGY, format="turtle")
    names = set()
    for prop_type in (OWL.ObjectProperty, OWL.DatatypeProperty):
        for s in g.subjects(RDF.type, prop_type):
            if str(s).startswith(str(GLOSS)):
                names.add(str(s).rsplit("/", 1)[-1])
    return names


def context_terms():
    ctx = json.load(open(CONTEXT))["@context"]
    terms = set()
    for k, v in ctx.items():
        if k.startswith("@"): continue
        iri = v["@id"] if isinstance(v, dict) else v
        if isinstance(iri, str) and iri.startswith("gloss:"):
            terms.add(iri[6:])
    return terms


def main():
    props = ontology_property_names()
    ctx = context_terms()
    missing = props - ctx
    if missing:
        print(f"FAIL: {len(missing)} ontology properties missing from JSON-LD context:",
              file=sys.stderr)
        for m in sorted(missing):
            print(f"  - gloss:{m}", file=sys.stderr)
        sys.exit(1)
    print(f"OK: all {len(props)} ontology properties have JSON-LD context entries")


if __name__ == "__main__":
    main()
```

## Wire into CI

Add to `.github/workflows/validate-schemas.yml`:

```yaml
  check-jsonld-context:
    name: Check JSON-LD context completeness
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install rdflib
      - run: python scripts/check-jsonld-context.py
```

## Verification

After item 01 fixes the 4 missing terms:

```bash
python scripts/check-jsonld-context.py
# Expected: OK: all N ontology properties have JSON-LD context entries
```

## Status: pending
