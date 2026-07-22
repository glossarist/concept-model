# 03 — P0: Tighten `$defs` with `additionalProperties: false`

## Problem

`schemas/v3/concept.yaml` has 17 `$defs`. Only ONE has
`additionalProperties: false`: `partitive_hyperedge` (added by the
hyperedge contributor).

Every other $def defaults to `additionalProperties: true`. The
schema accepts:

```yaml
related_concept:
  type: broader
  ref: { source: X, id: "1" }
  anything_you_want: true   # silently accepted
  another_typo_field: 42    # silently accepted
```

This means typos in field names — `contnet` instead of `content`,
`identfier` instead of `identifier` — pass validation silently.

## Fix

Add `additionalProperties: false` to every object-shaped $def:

- `concept_status` (enum — no props to lock down, but be explicit)
- `concept_date`
- `concept_date_type`
- `related_concept`
- `related_concept_type`
- `reference`
- `citation`
- `citation_ref`
- `concept_ref`
- `partitive_enumeration`
- `plurality_marker`
- `concept_source`
- `concept_source_type`
- `concept_source_status`
- `locality`
- `iso639_three_char_code` (already a regex pattern; can skip)

Also on the top-level schema and on `properties.data`.

## Risk

Existing YAML files with deprecated or unrecognized fields will
fail validation. Mitigation: run `validate-examples.py` after the
change; if any example breaks, either fix the example or add the
missing field to the schema.

## Verification

```bash
python3 -c "
import yaml
spec = yaml.safe_load(open('schemas/v3/concept.yaml'))
for name, defn in spec.get('\$defs', {}).items():
    if isinstance(defn, dict) and defn.get('type') == 'object':
        ap = defn.get('additionalProperties', 'MISSING')
        if ap != False:
            print(f'  LEAKY: {name}')
"
python scripts/validate-examples.py  # must still pass
```

## Status: pending
