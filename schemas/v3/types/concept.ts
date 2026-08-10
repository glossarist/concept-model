// AUTO-GENERATED from schemas/v3/concept.yaml by exe/generate-types-from-schemas.
// DO NOT EDIT by hand. Edit the schema, then re-run the generator.

// iso639_three_char_code: string alias

/**
 * The normative status of the managed term.
 */
export type ConceptStatus =
  | 'draft'
  | 'submitted'
  | 'not_valid'
  | 'invalid'
  | 'valid'
  | 'superseded'
  | 'retired'
  | 'external'

export const CONCEPT_STATUS_VALUES: ConceptStatus[] = [
  'draft',
  'submitted',
  'not_valid',
  'invalid',
  'valid',
  'superseded',
  'retired',
  'external',
];

/**
 * Whether the concept corresponds to a category of objects (`general`) or to a single unique object (`individual`).  Per ISO 704:2022 §5.2-5.3:   - General concepts are designated by terms or symbols   - Individual concepts are designated by proper names     (appellations) or symbols  Individual concepts occupy the bottom rung of a concept ladder and cannot be subdivided into more specific concepts, but CAN be subdivided into parts via a partitive relation.  Defaults to `general` when omitted.
 */
export type ConceptType =
  | 'general'
  | 'individual'

export const CONCEPT_TYPE_VALUES: ConceptType[] = [
  'general',
  'individual',
];

export interface ConceptDate {
  /** The date associated with the managed term. */
  date: string;
  type: ConceptDateType;
}

/**
 * Kinds of governance events associated with the lifecycle of a managed term.
 */
export type ConceptDateType =
  | 'accepted'
  | 'amended'
  | 'retired'
  | 'review'
  | 'review_decision'

export const CONCEPT_DATE_TYPE_VALUES: ConceptDateType[] = [
  'accepted',
  'amended',
  'retired',
  'review',
  'review_decision',
];

export interface RelatedConcept {
  type?: RelatedConceptType;
  ref?: ConceptRef;
  /** Free-form localized text describing the relationship, keyed by ISO 639 language code: `{ "eng": "...", "fra": "..." }`.  All free-form text fields in Glossarist are localized — the project is multi-language by domain. Plain strings are NOT accepted; wrap single-language text as `{ "eng": "..." }`. */
  content?: Record<string, string>;
}

/**
 * The relation of a term to the current term.
 */
export type RelatedConceptType =
  | 'deprecates'
  | 'deprecated_by'
  | 'supersedes'
  | 'superseded_by'
  | 'replaces'
  | 'replaced_by'
  | 'invalidates'
  | 'invalidated_by'
  | 'retires'
  | 'retired_by'
  | 'broader'
  | 'narrower'
  | 'broader_generic'
  | 'narrower_generic'
  | 'broader_partitive'
  | 'narrower_partitive'
  | 'has_part'
  | 'is_part_of'
  | 'broader_instantial'
  | 'narrower_instantial'
  | 'instance_of'
  | 'has_instance'
  | 'equivalent'
  | 'exact_match'
  | 'close_match'
  | 'broad_match'
  | 'narrow_match'
  | 'related_match'
  | 'see'
  | 'references'
  | 'related_concept'
  | 'related_concept_broader'
  | 'related_concept_narrower'
  | 'enhances'
  | 'enhanced_by'
  | 'contains'
  | 'contained_by_container'
  | 'contained_by_contained'
  | 'attaches'
  | 'attached_to'
  | 'made_of'
  | 'material_of'
  | 'has_property'
  | 'property_of'
  | 'owns'
  | 'owned_by'
  | 'ranks_above'
  | 'ranks_below'
  | 'causes'
  | 'caused_by'
  | 'develops_into'
  | 'develops_from'
  | 'performed_by'
  | 'performs_action'
  | 'done_by_method'
  | 'method_of'
  | 'done_at'
  | 'place_of_action'
  | 'done_for_purpose'
  | 'purpose_of_action'
  | 'done_for_beneficiary'
  | 'beneficiary_of_action'
  | 'acts_on_object'
  | 'object_of_action'
  | 'done_with_tool'
  | 'tool_of_action'
  | 'acts_on_patient'
  | 'patient_of_action'
  | 'produces'
  | 'produced_by'
  | 'made_from_ingredient'
  | 'ingredient_of'
  | 'produced_by_instrument'
  | 'instrument_product_of'
  | 'employed_by_professional'
  | 'employs_tool'
  | 'handled_by_tool'
  | 'tool_handles'
  | 'applied_to_patient'
  | 'patient_of_tool'
  | 'controlled_by'
  | 'controls'
  | 'represented_by'
  | 'represents'
  | 'originates_from'
  | 'origin_of'
  | 'sends_to'
  | 'receives_from'
  | 'sends_object'
  | 'object_sent_by'
  | 'opposite_of'
  | 'compare'
  | 'contrast'
  | 'sequentially_related'
  | 'spatially_related'
  | 'temporally_related'
  | 'homograph'
  | 'false_friend'
  | 'has_concept'
  | 'is_concept_of'
  | 'has_definition'
  | 'definition_of'
  | 'inherits'
  | 'inherited_by'
  | 'has_version'
  | 'version_of'
  | 'current_version'
  | 'current_version_of'
  | 'abbreviated_form_for'
  | 'short_form_for'
  | 'provides'
  | 'provided_by'

export const RELATED_CONCEPT_TYPE_VALUES: RelatedConceptType[] = [
  'deprecates',
  'deprecated_by',
  'supersedes',
  'superseded_by',
  'replaces',
  'replaced_by',
  'invalidates',
  'invalidated_by',
  'retires',
  'retired_by',
  'broader',
  'narrower',
  'broader_generic',
  'narrower_generic',
  'broader_partitive',
  'narrower_partitive',
  'has_part',
  'is_part_of',
  'broader_instantial',
  'narrower_instantial',
  'instance_of',
  'has_instance',
  'equivalent',
  'exact_match',
  'close_match',
  'broad_match',
  'narrow_match',
  'related_match',
  'see',
  'references',
  'related_concept',
  'related_concept_broader',
  'related_concept_narrower',
  'enhances',
  'enhanced_by',
  'contains',
  'contained_by_container',
  'contained_by_contained',
  'attaches',
  'attached_to',
  'made_of',
  'material_of',
  'has_property',
  'property_of',
  'owns',
  'owned_by',
  'ranks_above',
  'ranks_below',
  'causes',
  'caused_by',
  'develops_into',
  'develops_from',
  'performed_by',
  'performs_action',
  'done_by_method',
  'method_of',
  'done_at',
  'place_of_action',
  'done_for_purpose',
  'purpose_of_action',
  'done_for_beneficiary',
  'beneficiary_of_action',
  'acts_on_object',
  'object_of_action',
  'done_with_tool',
  'tool_of_action',
  'acts_on_patient',
  'patient_of_action',
  'produces',
  'produced_by',
  'made_from_ingredient',
  'ingredient_of',
  'produced_by_instrument',
  'instrument_product_of',
  'employed_by_professional',
  'employs_tool',
  'handled_by_tool',
  'tool_handles',
  'applied_to_patient',
  'patient_of_tool',
  'controlled_by',
  'controls',
  'represented_by',
  'represents',
  'originates_from',
  'origin_of',
  'sends_to',
  'receives_from',
  'sends_object',
  'object_sent_by',
  'opposite_of',
  'compare',
  'contrast',
  'sequentially_related',
  'spatially_related',
  'temporally_related',
  'homograph',
  'false_friend',
  'has_concept',
  'is_concept_of',
  'has_definition',
  'definition_of',
  'inherits',
  'inherited_by',
  'has_version',
  'version_of',
  'current_version',
  'current_version_of',
  'abbreviated_form_for',
  'short_form_for',
  'provides',
  'provided_by',
];

export interface Reference {
  /** Collection identifier (document series, termbase, vocabulary). */
  source?: string;
  /** Item identifier within the collection (document ID, concept ID). */
  id?: string;
  /** Alias for id (backward compatibility). */
  concept_id?: string;
  /** Version of the item or collection. */
  version?: string;
  locality?: Locality;
  /** URL link to the source document or concept. */
  link?: string;
  /** Pre-parsed original text. */
  original?: string;
  custom_locality?: Record<string, string>[];
  /** Type qualifier (domain, local, urn, designation). */
  ref_type?: string;
  /** Direct URN reference. */
  urn?: string;
  /** Term text when referencing a concept. */
  term?: string;
}

export interface Citation {
  ref?: CitationRef;
  locality?: Locality;
  /** URL link to the source document. */
  link?: string;
  /** Pre-parsed original citation text. */
  original?: string;
  custom_locality?: Record<string, string>[];
}

export interface CitationRef {
  /** Document series or termbase (e.g. "ISO", "IEC"). */
  source?: string;
  /** Document identifier within the series (e.g. "1087-1:2000"). */
  id?: string;
  /** Version of the document. */
  version?: string;
}

export interface ConceptRef {
  /** Registry or vocabulary identifier (e.g. "IEC", "ISO"). */
  source?: string;
  /** Concept identifier within the registry (e.g. "102-01-01"). */
  id?: string;
  /** Target designation text for lexical relationships, or the placeholder label for an unresolved external concept. */
  text?: string;
  /** When true, this ConceptRef references a parenthetical/external concept — one taken as a primitive in the current analysis but not formally defined in this dataset. The renderer shows the text in parentheses: (text). No separate concept file required. Mutually exclusive with `source`/`id`. */
  external?: boolean;
  /** When true, this ConceptRef represents a known gap — a member position that exists but whose target is unidentified. The renderer shows "..." at this position. Mutually exclusive with all other fields. */
  ellipsis?: boolean;
}

/**
 * Whether the partitives of a PartitiveRelation fitted together constitute the whole comprehensive concept (complete) or only some of it (partial — other partitives exist that are not encoded).
 */
export type Completeness =
  | 'complete'
  | 'partial'

export const COMPLETENESS_VALUES: Completeness[] = [
  'complete',
  'partial',
];

/**
 * Whether this partitive member must exist in every instance (required) or may exist in some instances only (optional).  ISO 704:2022 encodes this as the line style: solid (required) vs dashed (optional). Defaults to required when omitted.
 */
export type PartitivePresence =
  | 'required'
  | 'optional'

export const PARTITIVE_PRESENCE_VALUES: PartitivePresence[] = [
  'required',
  'optional',
];

/**
 * How many instances of this partitive member exist.  ISO 704:2022 encodes this via the number of lines in the diagram notation (1 line = exactly_one or at_least_one; 2 lines = multiple). Defaults to exactly_one when omitted.  The combination presence: optional + count: at_least_one is invalid — if a part is optional, at_least_one is vacuous and collapses to (optional, multiple).
 */
export type PartitiveCount =
  | 'exactly_one'
  | 'at_least_one'
  | 'multiple'

export const PARTITIVE_COUNT_VALUES: PartitiveCount[] = [
  'exactly_one',
  'at_least_one',
  'multiple',
];

/**
 * The definition strategy, per ISO 704:2022 §5.3. Used on DetailedDefinition#type. Defaults to intensional when omitted.  See docs/design/definition-types.md for the rationale and rendering guidance per type.
 */
export type DefinitionType =
  | 'intensional'
  | 'extensional'
  | 'partitive'
  | 'translated'

export const DEFINITION_TYPE_VALUES: DefinitionType[] = [
  'intensional',
  'extensional',
  'partitive',
  'translated',
];

export interface Locality {
  /** Type of the locality (section, clause, page, etc.) */
  type?: string;
  reference_from?: string;
  reference_to?: string;
}

/**
 * Type of concept source.
 */
export type ConceptSourceType =
  | 'authoritative'
  | 'lineage'

export const CONCEPT_SOURCE_TYPE_VALUES: ConceptSourceType[] = [
  'authoritative',
  'lineage',
];

/**
 * The status of the managed term relative to the source.
 */
export type ConceptSourceStatus =
  | 'identical'
  | 'similar'
  | 'modified'
  | 'restyle'
  | 'context_added'
  | 'generalisation'
  | 'specialisation'
  | 'unspecified'
  | 'related'
  | 'not_equal'

export const CONCEPT_SOURCE_STATUS_VALUES: ConceptSourceStatus[] = [
  'identical',
  'similar',
  'modified',
  'restyle',
  'context_added',
  'generalisation',
  'specialisation',
  'unspecified',
  'related',
  'not_equal',
];

export interface ConceptSource {
  /** Optional stable identifier for the source, used by inline `{{cite:id}}` references in the concept's text. The id is local to the concept; it must be unique within the concept's sources list (across concept-level, localization-level, and designation-level sources). */
  id?: string;
  type?: ConceptSourceType;
  status?: ConceptSourceStatus;
  origin?: Citation;
  /** How the concept was modified from the source. */
  modification?: string;
  /** Citations to the documents that this source was itself sourced from. Only valid on sources of type `lineage`; authoritative sources are terminal. When present, `status` and `modification` describe how `origin` relates to these upstream sources. Each citation MUST include a `locality` so the reader can locate the definition in the upstream document. */
  sourced_from?: any[];
}

