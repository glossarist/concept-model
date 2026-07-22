# 15 — P2: Generate JSON-LD context from ontology

## Problem

The JSON-LD context is hand-curated (272 lines). Every new
ontology property requires manually adding the context entry.
Item 05 catches drift; this item eliminates the maintenance.

## Fix

Write `scripts/generate-jsonld-context.py`:

```python
#!/usr/bin/env python3
"""Generate ontologies/glossarist.context.jsonld from the ontology.

For every owl:ObjectProperty, emit `"name": { "@id": "gloss:name", "@type": "@id" }`.
For every owl:DatatypeProperty, emit `"name": { "@id": "gloss:name", "@type": "xsd:string" }`
(default; can be overridden by a side-table).
For every owl:Class, emit `"ClassName": "gloss:ClassName"`.

Output: ontologies/glossarist.context.jsonld
"""
```

### Override file

A small `scripts/jsonld-overrides.yaml` for properties needing
non-default behavior (e.g. `xsd:boolean`, `xsd:anyURI`,
`xsd:dateTime`):

```yaml
datatype_overrides:
  isInternational: xsd:boolean
  isAbsent: xsd:boolean
  uri: xsd:anyURI
  urn: xsd:anyURI
  refLink: xsd:anyURI
  dateValue: xsd:dateTime
  # ...
```

### Workflow

Two options:

#### A. Check-in generated file (simpler)

- Generator runs in CI; if regenerated file differs from check-in,
  CI fails.
- Contributor runs `python scripts/generate-jsonld-context.py`
  locally and commits the result.

#### B. Generate at install time (cleaner but more setup)

- Add a `pre-publish` hook that regenerates the context.
- The check-in file is the source of truth; changes to the
  ontology regenerate the context on the next release.

Recommended: **A**. Lower friction.

## Verification

```bash
python scripts/generate-jsonld-context.py
diff ontologies/glossarist.context.jsonld{.generated,}
# (no diff = in sync)
```

## Out of scope for this PR

Generator + override file + CI check. Document the workflow in
CONTRIBUTING.md.

## Status: pending (P2 — large change)
