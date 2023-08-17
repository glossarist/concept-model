This document provides documentation for a YAML concept in glossarist V2 format.

## Concept

- **id:**
  - **Description:** A unique identifier(UUID) for the concept.
  - **Example:** `id: 01fa30d3-4e4b-4142-b68a-c299b55b3fb8`

- **status:**
  - **Description:** Status of the concept.
  - **Example:** `status: valid`

- **dateAccepted:**
  - **Description:** Date and time when the concept was accepted.
  - **Example:** `dateAccepted: 2023-08-04T11:33:09.535Z`

- **Data:**
  - **Description:** Data related to the concept.
  - **Example:**
    ```yaml
    identifier: '88'
    localizedConcepts:
        eng: 2b959537-c600-41d1-aeb7-7233c35d30eb
    ```
  - **Details**
    - **identifier:**
      - **Description:** An identifier for the concept being discussed.
      - **Example:** `identifier: '88'`
    - **localizedConcepts**
      - **Details:** Three digit language code followed by the `id` of the localization for that language.
      - **Example**
        ```yaml
        eng: 2b959537-c600-41d1-aeb7-7233c35d30eb
        ara: 04b276ad-f69e-45b7-a908-9c61fa94697f
        ```
### Example:

filename: `concepts/01fa30d3-4e4b-4142-b68a-c299b55b3fb8.yaml`
```yaml
id: 01fa30d3-4e4b-4142-b68a-c299b55b3fb8
data:
  identifier: '88'
  localizedConcepts:
    eng: 2b959537-c600-41d1-aeb7-7233c35d30eb
status: valid
dateAccepted: 2023-08-04T11:33:09.535Z
```

## Localized Concept

- **id:**
  - **Description:** A unique identifier(UUID) for the localized concept.
  - **Example:** `id: 04b276ad-f69e-45b7-a908-9c61fa94697f`

- **Data:**
  - **Description:** The data related to the concept.
  - **Example:**
    ```yaml
    data:
      language_code: eng
      terms:
        - normative_status: preferred
          type: expression
          designation: geometry node
      definition:
        - content: >-
           {{urn:iso:std:iso:19775:65,node}} containing mathematical descriptions
           of points, lines, surfaces, text strings and solids
      notes: []
      examples: []
      authoritativeSource:
        - link: https://www.web3d.org/specifications/X3Dv4Draft/ISO-IEC19775-1v4-IS.proof/Part01/glossary.html#GeometryNode
    ```
  - **Details**
    - **language_code:**
      - **Description:** Three digit language code for the current localization.
      - **Example:** `language_code: eng`
    - **terms**
      - **Details:** List of terms(designations) for the concept.
      - **Example**
        ```yaml
        terms:
          - normative_status: preferred
            type: expression
            designation: geometry node
        ```
    - **definition:**
      - **Description:** List of all the definitons for current localization.
      - **Example:**
        ```yaml
        definition:
          - content: >-
             {{urn:iso:std:iso:19775:65,node}} containing mathematical descriptions
             of points, lines, surfaces, text strings and solids
        ```
    - **notes:**
      - **Description:** List of notes for current localization.
      - **Example:**
        ```yaml
        notes:
          - content: first note
          - content: second note
        ```
    - **examples:**
      - **Description:** List of all examples for current localization.
      - **Example:**
        ```yaml
        examples:
          - content: first example
          - content: second example
        ```
    - **authoritativeSource:**
      - **Description:** authoritative source for current localization.
      - **Example:**
        ```yaml
        authoritativeSource:
          - link: https://www.web3d.org/specifications/X3Dv4Draft/ISO-IEC19775-1v4-IS.proof/Part01/glossary.html#GeometryNode
        ```
- **status:**
  - **Description:** This is a unique identifier(UUID) for the concept.
  - **Example:** `status: valid`
- **dateAccepted:**
  - **Description:** This is a unique identifier(UUID) for the concept.
  - **Example:** `dateAccepted: 2023-08-04T11:33:09.535Z`

### Example

filename: `localized-concepts/04b276ad-f69e-45b7-a908-9c61fa94697f.yaml`
```yaml
id: 04b276ad-f69e-45b7-a908-9c61fa94697f
data:
  language_code: eng
  terms:
    - normative_status: preferred
      type: expression
      designation: geometry node
  definition:
    - content: >-
        {{urn:iso:std:iso:19775:65,node}} containing mathematical descriptions
        of points, lines, surfaces, text strings and solids
  notes: []
  examples: []
  authoritativeSource:
    - link: >-
        https://www.web3d.org/specifications/X3Dv4Draft/ISO-IEC19775-1v4-IS.proof/Part01/glossary.html#GeometryNode
status: valid
dateAccepted: 2023-08-04T11:33:09.535Z
```
