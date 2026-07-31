// AUTO-GENERATED from schemas/v3/relation.yaml by exe/generate-types-from-schemas.
// DO NOT EDIT by hand. Edit the schema, then re-run the generator.

export interface ConceptSystemMember {
  ref: Concept.yamlconceptRef;
  presence?: Concept.yamlpartitivePresence;
  count?: Concept.yamlpartitiveCount;
  /** ISO 704:2022 delimiting member (bold 3x-width line in diagram). When true, this member behaves like a delimiting characteristic: it distinguishes the comprehensive from coordinate concepts.  Orthogonal to presence and count. Defaults to false. */
  is_delimiting?: boolean;
}

