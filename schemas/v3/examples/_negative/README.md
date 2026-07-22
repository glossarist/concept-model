# Negative test cases

Each YAML in this directory is intentionally broken. The schema
MUST reject every one. The `scripts/validate-negative-examples.py`
runner asserts this — if any negative example passes validation,
the schema has been loosened too far.

Naming: `NN-description.yaml` mirrors the positive-example numbering
where applicable.

| File | Tests rejection of |
|------|---------------------|
| 01-missing-comprehensive.yaml | required `comprehensive` field absent |
| 02-empty-parts.yaml | `parts` array empty (violates minItems: 1) |
| 03-invalid-enumeration.yaml | `enumeration` value not in {closed, open} |
| 04-invalid-marker.yaml | `markers` value not in {double, dashed} |
| 05-self-loop.yaml | comprehensive appears in parts |
| 06-duplicate-markers.yaml | `markers: [double, double]` violates uniqueItems |
| 07-unknown-field-hyperedge.yaml | additional property on hyperedge (after additionalProperties: false) |
| 08-status-not-in-enum.yaml | `status: bogus` not in concept_status enum |
| 09-related-type-not-in-enum.yaml | `type: bogus_relationship` not in related_concept_type |
| 10-missing-data-identifier.yaml | `data.identifier` absent where required |
