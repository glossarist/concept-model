# 07 — P1: Fix pre-existing `status: current` enum gap

## Problem

`scripts/validate-examples.py` reports:

```
FAIL: 17-register-dataset.yaml[0]: 'current' is not one of
  ['draft','submitted','not_valid','invalid','valid','superseded','retired']
FAIL: 18-hierarchical-sections-register.yaml[0]: same
```

Both examples use `status: current`, which isn't in the enum. This
blocks wiring `validate-examples.py` into CI.

Pre-existing — not introduced by the contributor.

## Analysis

`status: current` is ambiguous:
- The lifecycle status of a register (always-current, never-expiring)
- vs. a concept's editorial status (draft → valid → superseded → retired)

Looking at examples 17 and 18, they're register datasets
(`17-register-dataset.yaml`, `18-hierarchical-sections-register.yaml`),
not concepts. They use the concept-status field for a different
purpose. The right fix is one of:

### Option A: Add `current` to the enum (loose)
Quick, backward compatible. But conflates two semantics — register
status vs. concept status.

### Option B: Add a separate `register_status` field (correct)
Define a new enum (`RegisterStatus`: `current`, `superseded`,
`retired`) for use on `DatasetRegister`. Update examples 17, 18.
Concept-status enum stays as-is.

### Option C: Use `valid` for registers
Update examples 17, 18 to use `status: valid`. The register is
"valid" in the sense of "not superseded."

## Recommended

**Option B** is semantically correct but adds scope. **Option C** is
the smallest change that unblocks CI without semantic drift. **Option
A** is wrong — it conflates two different concerns.

Pick Option C for now (one-line edit per example), file Option B as
a follow-up if registers proliferate.

## Fix (Option C)

```bash
# In schemas/v3/examples/17-register-dataset.yaml
-status: current
+status: valid

# In schemas/v3/examples/18-hierarchical-sections-register.yaml
-status: current
+status: valid
```

## Verification

```bash
python scripts/validate-examples.py
# Expected: 0 failures
```

## Status: pending
