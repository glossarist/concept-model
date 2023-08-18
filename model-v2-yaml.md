## Concept

Filename: `concepts/02bafb0f-2f09-541c-9224-5dedcf4f9a8e.yaml`

```yaml
# data related to the concept
data:
  identifier: '939' # An identifier for the concept being discussed.

  # List of all localizations for the concept
  # The format is <3 digit language code>: <id of the localized-concept>
  localizedConcepts:
    ara: 19bb3553-fc74-535f-9ee8-c2db597d9269
    deu: f27b0718-0a9e-5602-85d4-33952af2f91b
    eng: c1b210f5-21ac-5a8b-8bf3-a34e5de7bddb
    kor: 61361462-65ba-59f4-9f25-31796bb38578
    rus: 8d61d10d-18a3-5888-be8e-ba7c0f480957
    spa: 886155b6-7158-5de2-822d-400f6d20fada
    swe: 7da14dec-ff6c-5e1e-807f-8611f946f1aa

# Date and time when the concept was accepted.
dateAccepted: 2023-04-17

# A UUID for the concept
id: 02bafb0f-2f09-541c-9224-5dedcf4f9a8e

# List of all the related concepts
related: []

# Status of the concept
status: valid
```

## Localized Concept

Filename: `localized-concepts/c1b210f5-21ac-5a8b-8bf3-a34e5de7bddb.yaml`

```yaml
# data related to the concept
data:

  # Authoritative source for current localized concept.
  # This can also be added below in the sources section with type `authoritative`
  authoritativeSource:
  - {}

  # Different dates related to this localized concept
  dates:
  - date: '2010-06-15T00:00:00.000Z'
    type: accepted

  # Definitions list for this localized concept
  definition:
  - content: sensor that detects and collects all of the data for an image (frame / rectangle) at an instant of time

  # List of examples
  examples: []

  # Identifier
  id: 939

  # 3 digit language code for this localized concept
  language_code: eng

  lineage_source_similarity: '1'

  # List of notes for the this localized concept
  notes: []

  # Release version of the current localization
  release: '2'

  # Review date for the current localized concept
  # This can also be added in dates section above
  reviewDate: 2018-09-01

  # Review decision date for the current localized concept
  reviewDecisionDate: 2018-09-01

  reviewDecisionEvent: Publication of ISO 19130-1:2018(E)

  # Review decision for the localized concept
  review_decision: accepted

  # Review notes for this localized concept
  # Can be added in notes section above
  review_decision_notes: Authoritative reference changed from ISO/TS 19130:2010 to
    ISO 19130-1:2018(E), 3.28. Lineage source added as ISO/TS 19130:2010(E)

  # Review status for this localized concept
  review_status: final

  # List of sources for the current localized concept
  sources:
  # Authoritative source for the current localized concept
  - origin:
      clause: '3.28'
      link: https://www.iso.org/standard/66847.html
      ref: ISO 19130-1:2018
    # Type of the source
    type: authoritative
  - origin:
      ref: ISO/TS 19130:2010(E)
    # Type of the source
    type: lineage

  # List of terms used for this localized concept
  terms:
  - designation: frame sensor
    # normative status of the current designation(term).
    normative_status: preferred
    # type of the current designation(term).
    type: expression

# Date when this localization was accepted
# can also be writtent in dates list format as mentioned above.
dateAccepted: 2023-04-17

# ID of the current localized concept
id: c1b210f5-21ac-5a8b-8bf3-a34e5de7bddb

# status of the current localized concept
status: valid
```
