# 11 — P2: Clean up `validate-ontologies.py` no-op

## Problem

`scripts/validate-ontologies.py` lines 21-28 contain a "targetClass
cross-check" that ends with `pass`. The block parses, iterates, and
discards — it's dead code dressed as a check.

```python
for shape in g.subjects(None, SHACL.NodeShape):
    for target in g.objects(shape, SHACL.targetClass):
        local = str(target)
        if local.startswith(str(GLOSS)) and local not in [
            str(GLOSS) + s.split("#")[0] if "#" in s else s
            for s in g.subjects(None, None)
        ]:
            pass  # targetClass may reference classes defined in other files
```

The current behavior is: parse every Turtle file, return no errors
unless parse fails. Useful, but oversold.

## Fix

Replace the no-op with a real check (or delete the block).

### Option A: Delete the dead block

```python
def validate_ttl(path: Path) -> list[str]:
    errors = []
    g = Graph()
    try:
        g.parse(str(path), format="turtle")
    except Exception as e:
        errors.append(f"Parse error: {e}")
    return errors
```

Honest: the script checks parse-only. That's it.

### Option B: Implement targetClass cross-check across files

Parse all files into one graph, then check that every `sh:targetClass
gloss:X` resolves to an `owl:Class gloss:X` somewhere in the
ontology. This is what the original code aspired to.

```python
def validate_cross_references(ttl_files: list[Path]) -> list[str]:
    g = Graph()
    errors = []
    for p in ttl_files:
        try:
            g.parse(str(p), format="turtle")
        except Exception as e:
            errors.append(f"{p.name}: parse error: {e}")
    OWL = Namespace("http://www.w3.org/2002/07/owl#")
    SHACL = Namespace("http://www.w3.org/ns/shacl#")
    GLOSS = Namespace("https://www.glossarist.org/ontologies/")
    defined_classes = set(g.subjects(RDF.type, OWL.Class))
    for shape in g.subjects(None, SHACL.NodeShape):
        for target in g.objects(shape, SHACL.targetClass):
            if str(target).startswith(str(GLOSS)) and target not in defined_classes:
                errors.append(f"{shape} targets undefined class {target}")
    return errors
```

## Recommended: Option B

Closes a real gap — currently a typo in `sh:targetClass gloss:FooBar`
is invisible.

## Verification

After implementing Option B, run:
```bash
python scripts/validate-ontologies.py
```

If clean, every `sh:targetClass` resolves.

## Status: pending
