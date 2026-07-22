# 08 — P1: Rewrite `check-enum-drift.py`

## Problems

The current script has four issues. Each is a real OCP or coverage
gap.

### a) OCP hole: `ENUMS` list is hard-coded

```python
ENUMS = [
    ("partitive_enumeration", "partitiveEnumeration"),
    ("plurality_marker", "pluralityMarker"),
]
```

Adding a new enum to the schema requires editing this list. If
forgotten, drift on the new enum is invisible. Should auto-discover.

### b) Doesn't check SHACL `sh:valuesFrom` URIs

The script's own docstring promises:

> 2. Extract values from `ontologies/shapes/glossarist.shacl.ttl`
>    (the sh:valuesFrom target's taxonomy)

The implementation never touches SHACL. The URI typo
(`partitive-enumeration` vs `partitiveEnumeration`) is invisible to
this script.

### c) Doesn't check LUTAML model enums

The project treats the LUTAML model as the source of truth (per
`00-master-plan.md` I3). The drift checker doesn't read LUTAML at
all. Model ↔ schema drift is undetectable.

### d) Re-parses schema per enum

Minor inefficiency in `schema_enum_values(name)` — loads the schema
file on every call.

## Fix

Rewrite the script with:

1. **Auto-discover enums from schema `$defs`**: any `$def` with an
   `enum:` key is a known enum. Pair with the matching taxonomy
   by convention (kebab-case filename → camelCase `ConceptScheme`
   local name; assert at runtime).

2. **Load SHACL graph once**: extract every `sh:valuesFrom` URI.
   Assert each one resolves to a real `skos:ConceptScheme` in the
   taxonomy graph. Report broken URIs.

3. **LUTAML model cross-check**: parse `models/concepts/*.lutaml`
   (regex is sufficient — the syntax is regular). For each `enum X
   { ... }` block, extract the value names. Pair with the matching
   schema `$def`. Assert they match.

4. **Cache**: load schema, taxonomies, SHACL, LUTAML models exactly
   once per process.

## Skeleton

```python
#!/usr/bin/env python3
"""Detect enum drift across schema, SHACL, SKOS taxonomy, and LUTAML model.

For every enum declared in any of the four sources:
  1. schema $defs/<name> with `enum:` block
  2. SHACL shape with `sh:valuesFrom <scheme>`
  3. SKOS ConceptScheme in ontologies/taxonomies/
  4. LUTAML `enum X { ... }` declaration

Assert all sources that reference the same enum name agree on:
  - the set of values
  - the canonical scheme URI

Exits 0 on success, non-zero on any drift or broken reference.
"""

import re, sys
from pathlib import Path
import yaml
from rdflib import Graph, Namespace, RDF
from rdflib.namespace import SKOS

REPO = Path(__file__).resolve().parents[1]
SCHEMA_PATH = REPO / "schemas/v3/concept.yaml"
SHACL_PATH = REPO / "ontologies/shapes/glossarist.shacl.ttl"
TAXONOMIES_DIR = REPO / "ontologies/taxonomies"
MODELS_DIR = REPO / "models/concepts"

SHACL = Namespace("http://www.w3.org/ns/shacl#")
GLOSS = Namespace("https://www.glossarist.org/ontologies/")


def load_schema():
    return yaml.safe_load(SCHEMA_PATH.read_text())


def load_taxonomy_graph():
    g = Graph()
    for f in TAXONOMIES_DIR.glob("*.ttl"):
        g.parse(f, format="turtle")
    return g


def load_shacl_graph():
    g = Graph()
    g.parse(SHACL_PATH, format="turtle")
    return g


def schema_enums(schema):
    """Return {enum_name: set(values)} for every $def with an `enum:` block."""
    out = {}
    for name, defn in schema.get("$defs", {}).items():
        if isinstance(defn, dict) and "enum" in defn:
            out[name] = set(defn["enum"])
    return out


def taxonomy_schemes_and_values(g):
    """Return {scheme_uri: set(prefLabel values)} for every ConceptScheme."""
    out = {}
    for scheme in g.subjects(RDF.type, SKOS.ConceptScheme):
        values = set()
        for c in g.subjects(SKOS.inScheme, scheme):
            label = g.value(c, SKOS.prefLabel)
            if label is not None:
                values.add(str(label))
        out[str(scheme)] = values
    return out


def shacl_valuesfrom_uris(g):
    """Return set of scheme URIs referenced by sh:valuesFrom."""
    return set(str(o) for o in g.objects(None, SHACL.valuesFrom))


def lutaml_enum_values():
    """Parse LUTAML enum declarations. Returns {enum_name: set(values)}."""
    pattern = re.compile(r"^\s*enum\s+(\w+)\s*\{(.*?)^\s*\}", re.DOTALL | re.MULTILINE)
    member_pat = re.compile(r"^\s*(\w+)\s*(?:\{|$)", re.MULTILINE)
    out = {}
    for f in MODELS_DIR.glob("*.lutaml"):
        text = f.read_text()
        for m in pattern.finditer(text):
            name, body = m.group(1), m.group(2)
            members = set(member_pat.findall(body))
            members.discard("")  # filter false positives
            # Filter out non-value keywords that match the member pattern
            members = {v for v in members if v and not v.startswith("definition")}
            out[name] = members
    return out


def main():
    schema = load_schema()
    tax_g = load_taxonomy_graph()
    shacl_g = load_shacl_graph()

    schema_enums_map = schema_enums(schema)
    tax_schemes = taxonomy_schemes_and_values(tax_g)
    shacl_uris = shacl_valuesfrom_uris(shacl_g)
    lutaml_enums = lutaml_enum_values()

    failures = []

    # Check 1: every sh:valuesFrom URI must resolve to a real ConceptScheme.
    for uri in shacl_uris:
        if uri not in tax_schemes:
            failures.append(f"SHACL sh:valuesFrom target does not exist: {uri}")

    # Check 2: for each scheme, the taxonomy values must match any schema
    # enum that maps to it. We pair by convention: scheme local name
    # (camelCase) → kebab-case schema $def name.
    scheme_to_schema = {}
    for scheme_uri in tax_schemes:
        local = scheme_uri.rsplit("/", 1)[-1]
        # camelCase → snake_case
        snake = re.sub(r"(?<!^)(?=[A-Z])", "_", local).lower()
        scheme_to_schema[scheme_uri] = snake

    for scheme_uri, tax_values in tax_schemes.items():
        schema_name = scheme_to_schema[scheme_uri]
        if schema_name in schema_enums_map:
            if schema_enums_map[schema_name] != tax_values:
                failures.append(
                    f"DRIFT schema vs taxonomy for {schema_name}: "
                    f"schema={sorted(schema_enums_map[schema_name])} "
                    f"taxonomy={sorted(tax_values)}"
                )

    # Check 3: LUTAML model enums must match schema enums (by snake_case name).
    for enum_name, lutaml_values in lutaml_enums.items():
        snake = re.sub(r"(?<!^)(?=[A-Z])", "_", enum_name).lower()
        if snake in schema_enums_map:
            if schema_enums_map[snake] != lutaml_values:
                failures.append(
                    f"DRIFT schema vs LUTAML for {enum_name}: "
                    f"schema={sorted(schema_enums_map[snake])} "
                    f"lutaml={sorted(lutaml_values)}"
                )

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        sys.exit(1)

    print(f"OK: {len(tax_schemes)} taxonomies, "
          f"{len(schema_enums_map)} schema enums, "
          f"{len(shacl_uris)} SHACL refs, "
          f"{len(lutaml_enums)} LUTAML enums — all consistent")


if __name__ == "__main__":
    main()
```

## Verification

After running:
- Reports the URI typo in item 01 once that's fixed, this passes.
- Reports drift on any future enum mismatch.
- Catches LUTAML ↔ schema drift.

## Status: pending
