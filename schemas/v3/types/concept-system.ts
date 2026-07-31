// AUTO-GENERATED from schemas/v3/concept-system.yaml by exe/generate-types-from-schemas.
// DO NOT EDIT by hand. Edit the schema, then re-run the generator.

/**
 * The type of concept system per ISO 12620 A.7.1. The dominant relation type determines the system type; "mixed" covers the realistic case where multiple relation types coexist.
 */
export type ConceptSystemType =
  | 'generic'
  | 'partitive'
  | 'sequential'
  | 'associative'
  | 'mixed'

export const CONCEPT_SYSTEM_TYPE_VALUES: ConceptSystemType[] = [
  'generic',
  'partitive',
  'sequential',
  'associative',
  'mixed',
];

