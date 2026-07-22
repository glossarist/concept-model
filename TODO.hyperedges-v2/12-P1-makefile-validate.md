# 12 — P1: Makefile `validate` target

## Problem

Today running validation requires remembering 6 script names. The
existing `Makefile` only builds PNG diagrams from LUTAML — it
doesn't validate.

## Fix

Append to `Makefile`:

```make
.PHONY: validate validate-fast validate-scripts clean-verify

validate: validate-ontologies validate-examples check-enum-drift \
          check-jsonld-context check-shacl-coverage \
          check-lutaml-references
	@echo "All validation checks passed."

validate-ontologies:
	python scripts/validate-ontologies.py

validate-examples:
	python scripts/validate-examples.py

check-enum-drift:
	python scripts/check-enum-drift.py

check-jsonld-context:
	python scripts/check-jsonld-context.py

check-shacl-coverage:
	python scripts/check-shacl-coverage.py

check-lutaml-references:
	python scripts/check-lutaml-references.py

validate-scripts:
	pytest scripts/tests/ -v
```

## Usage

```bash
make validate     # run everything
make check-enum-drift  # just one
```

## Verification

```bash
make validate
```

## Status: pending
