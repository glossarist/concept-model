# 13 — P1: Clarify `Concept#domain` vs `Concept#subject`

## Problem

`models/concepts/Concept.lutaml` declares both:

```
+domain: <<BasicDocument>> LocalizedString [0..*] {
  definition { An optional semantic domain ... }
}

+subject: <<BasicDocument>> LocalizedString [0..1] {
  definition { Subject of the term. }
}
```

Both are LocalizedString. Both look like "what the term is about."
Authors will use them inconsistently.

Looking at the wire format, `data.domains` is the existing field
for subject-area classification. `data.subject` doesn't appear in
the schema. So `+subject` may be a vestigial model field that
never made it to the wire.

## Fix

Three options:

### A. Document the distinction (lowest risk)

Update both definitions to clearly distinguish:

```
+domain: <<BasicDocument>> LocalizedString [0..*] {
  definition {
    Subject area or knowledge domain the term belongs to, when
    ambiguity exists between several domains. Use the structured
    ConceptReference (data.domains) for the canonical wire-format
    classification; this field carries an optional free-text
    complement for human reading.
  }
}

+subject: <<BasicDocument>> LocalizedString [0..1] {
  definition {
    Topic or specific subject matter of the term, when distinct
    from its broader domain. Reserved for editorial metadata; not
    currently emitted in the v3 wire format.
  }
}
```

### B. Remove `+subject` (cleanest)

If the field isn't used on the wire and has no consumers, delete
it. Search glossarist-ruby, glossarist-js, concept-browser for
`subject` references before deleting.

### C. Merge (most aggressive)

Drop `+subject`, expand `+domain` to be the single field.

## Recommended: A (document)

Until consumer usage is audited, document the distinction. File
B/C as a follow-up cleanup PR after consumer audit.

## Verification

```bash
grep -A3 "+domain\|+subject" models/concepts/Concept.lutaml
```

## Status: pending
