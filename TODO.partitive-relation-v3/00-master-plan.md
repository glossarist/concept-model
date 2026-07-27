# TODO.partitive-relation-v3 — Cleanup after ISO 704:2022 multiplicity correction

## What this addresses

After PR #75 (multiplicity + is_delimiting) and PR #76 (rename
at_least_one, drift fix, stale docs), remaining gaps:

- Design doc references old enum value name
- No examples for 3 of 5 multiplicity values
- No negative test for non-boolean is_delimiting
- Examples README coverage table doesn't list multiplicity values
- No spec for the new multiplicity/delimiting coherence check

## Items

| # | Priority | Title |
|---|----------|-------|
| 01 | P0 | Fix design doc: at_least_one → compulsory_at_least_one |
| 02 | P1 | Add example for compulsory_multiple multiplicity |
| 03 | P1 | Add example for optional_multiple multiplicity |
| 04 | P1 | Add example for compulsory_at_least_one multiplicity |
| 05 | P1 | Add negative test for non-boolean is_delimiting |
| 06 | P1 | Update examples README coverage table for multiplicity |
| 07 | P1 | Add RSpec test for multiplicity/delimiting coherence validator |
