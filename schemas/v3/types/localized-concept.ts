// AUTO-GENERATED from schemas/v3/localized-concept.yaml by exe/generate-types-from-schemas.
// DO NOT EDIT by hand. Edit the schema, then re-run the generator.

export interface DesignationBase {
  normative_status?: NormativeStatus;
  /** Indication that the term designation is missing. */
  absent?: boolean;
  /** Text used to disambiguate a designation by describing the subject field. */
  field_of_application?: string;
  /** Text used to disambiguate a designation by describing how it is used. */
  usage_info?: string;
  /** The geographic area in which the managed term is known under this designation. */
  geographical_area?: Iso3166Code[];
  /** Bibliographic references for this designation. */
  sources?: ConceptSource[];
  term_type?: TermType;
  /** Designation-level relationships (e.g. abbreviated_form_for, short_form_for). */
  related?: DesignationRelationship[];
  register?: Register;
}

export interface Pronunciation {
  /** The phonetic transcription text. */
  content?: string;
  language?: Iso639ThreeCharCode;
  script?: Iso15924Code;
  /** The transcription system (e.g. IPA, romaji). */
  system?: string;
  country?: Iso3166Code;
}

/**
 * Type of abbreviation, according to how it is formed.
 */
export type AbbreviationType =
  | 'truncation'
  | 'acronym'
  | 'initialism'
  | 'other'

export const ABBREVIATION_TYPE_VALUES: AbbreviationType[] = [
  'truncation',
  'acronym',
  'initialism',
  'other',
];

/**
 * Normative status of a designation of a term.
 */
export type NormativeStatus =
  | 'preferred'
  | 'admitted'
  | 'deprecated'
  | 'superseded'

export const NORMATIVE_STATUS_VALUES: NormativeStatus[] = [
  'preferred',
  'admitted',
  'deprecated',
  'superseded',
];

/**
 * Status of the localized concept entry.
 */
export type EntryStatus =
  | 'valid'
  | 'not_valid'
  | 'superseded'
  | 'retired'

export const ENTRY_STATUS_VALUES: EntryStatus[] = [
  'valid',
  'not_valid',
  'superseded',
  'retired',
];

/**
 * ISO 12620 term type classification.
 */
export type TermType =
  | 'full_form'
  | 'variant'
  | 'entry_term'
  | 'common_name'
  | 'synonym'
  | 'transliterated_form'
  | 'transcribed_form'
  | 'scientific_name'
  | 'short_form'
  | 'acronym'
  | 'initialism'
  | 'abbreviation'
  | 'truncation'
  | 'symbol'
  | 'equation'
  | 'formula'
  | 'reference_symbol'
  | 'figure_symbol'
  | 'graphic_symbol'
  | 'letter_symbol'
  | 'roman_numeral'
  | 'mathematical_expression'
  | 'code'
  | 'phrase'
  | 'clipped_term'
  | 'logical_expression'
  | 'internationalism'
  | 'international_scientific_term'
  | 'part_number'
  | 'phraseological_unit'
  | 'shortcut'
  | 'sku'
  | 'standard_text'
  | 'synonymous_phrase'

export const TERM_TYPE_VALUES: TermType[] = [
  'full_form',
  'variant',
  'entry_term',
  'common_name',
  'synonym',
  'transliterated_form',
  'transcribed_form',
  'scientific_name',
  'short_form',
  'acronym',
  'initialism',
  'abbreviation',
  'truncation',
  'symbol',
  'equation',
  'formula',
  'reference_symbol',
  'figure_symbol',
  'graphic_symbol',
  'letter_symbol',
  'roman_numeral',
  'mathematical_expression',
  'code',
  'phrase',
  'clipped_term',
  'logical_expression',
  'internationalism',
  'international_scientific_term',
  'part_number',
  'phraseological_unit',
  'shortcut',
  'sku',
  'standard_text',
  'synonymous_phrase',
];

/**
 * The grammatical gender of the designation.
 */
export type GrammarGender =
  | 'masculine'
  | 'feminine'
  | 'neuter'
  | 'common'

export const GRAMMAR_GENDER_VALUES: GrammarGender[] = [
  'masculine',
  'feminine',
  'neuter',
  'common',
];

/**
 * The grammatical number of the designation.
 */
export type GrammarNumber =
  | 'singular'
  | 'dual'
  | 'plural'
  | 'mass'
  | 'other_number'

export const GRAMMAR_NUMBER_VALUES: GrammarNumber[] = [
  'singular',
  'dual',
  'plural',
  'mass',
  'other_number',
];

export interface GrammarInfo {
  gender?: GrammarGender;
  number?: GrammarNumber;
  /** The designation is a preposition. */
  preposition?: boolean;
  /** The designation is a participle. */
  participle?: boolean;
  /** The designation is an adjective. */
  adj?: boolean;
  /** The designation is a verb. */
  verb?: boolean;
  /** The designation is an adverb. */
  adverb?: boolean;
  /** The designation is a noun. */
  noun?: boolean;
  part_of_speech?: PartOfSpeech;
}

/**
 * Status of the concept
 */
export type ConceptStatus =
  | 'draft'
  | 'submitted'
  | 'not_valid'
  | 'invalid'
  | 'valid'
  | 'superseded'
  | 'retired'

export const CONCEPT_STATUS_VALUES: ConceptStatus[] = [
  'draft',
  'submitted',
  'not_valid',
  'invalid',
  'valid',
  'superseded',
  'retired',
];

export interface ConceptDate {
  date?: string;
  type?: ('accepted' | 'amended' | 'retired' | 'review' | 'review_decision');
  /** MANAGEMENT — Free-text description of the governance event. */
  event_description?: string;
}

/**
 * Status of the concept source
 */
export type ConceptSourceStatuses =
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

export const CONCEPT_SOURCE_STATUSES_VALUES: ConceptSourceStatuses[] = [
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

/**
 * Type of the concept source
 */
export type ConceptSourceTypes =
  | 'authoritative'
  | 'lineage'

export const CONCEPT_SOURCE_TYPES_VALUES: ConceptSourceTypes[] = [
  'authoritative',
  'lineage',
];

export interface ConceptSource {
  /** Optional stable identifier for the source, used by inline `{{cite:id}}` references in the concept's text. */
  id?: string;
  status?: ConceptSourceStatuses;
  type?: ConceptSourceTypes;
  origin?: Citation;
  /** Modification of the concept source */
  modification?: string;
  /** Citations to the documents that this source was itself sourced from. Only valid on sources of type `lineage`; authoritative sources are terminal. When present, `status` and `modification` describe how `origin` relates to these upstream sources. */
  sourced_from?: Citation[];
}

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
  /** Registry or vocabulary identifier. */
  source?: string;
  /** Concept identifier within the registry. */
  id?: string;
  /** Target designation text for lexical relationships. */
  text?: string;
}

export interface Locality {
  /** Type of the locality (section, clause, page, etc.) */
  type?: string;
  reference_from?: string;
  reference_to?: string;
}

export interface DetailedDefinition {
  /** The text content. */
  content?: string;
  type?: DefinitionType;
  /** Bibliographic references for this content. */
  sources?: ConceptSource[];
  /** Examples scoped to this entry (VIM 1993 style: EXAMPLE entries nested inside a NOTE or definition). Empty when the example is concept-level, in which case it lives on the concept's top-level examples collection directly. */
  examples?: DetailedDefinition[];
}

/**
 * The definition strategy, per ISO 704:2022 §5.3. Defaults to intensional when omitted. See docs/design/definition-types.md.
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

export interface RelatedConcept {
  /** The type of relationship. */
  type?: string;
  ref?: ConceptRef;
  /** Text describing the relationship. */
  content?: string;
}

export interface DesignationRelationship {
  /** The type of designation relationship. */
  type: ('abbreviated_form_for' | 'short_form_for' | 'homograph_of' | 'antonym_of');
  /** Text describing the designation relationship. */
  content?: string;
  /** The target designation text that this designation relates to. */
  target?: string;
  /** For homograph_of: the ConceptRef of the OTHER concept that has a designation with the same `target` text. Required for homograph_of; optional for antonym_of; not used for abbreviated_form_for / short_form_for. */
  target_concept?: ConceptRef;
}

// iso639_three_char_code: string alias

// iso3166_code: string alias

// iso15924_code: string alias

// iso24229_code: string alias

/**
 * The degree of equivalence between this localization and the concept's reference-language definition.  Per ISO 704:2022 §7.7.3:   - full (default): equivalent intension across languages   - partial: overlapping but not identical intension   - none: no corresponding concept in this language   - directional: monodirectional equivalence (see equivalence_note)
 */
export type EquivalenceDegree =
  | 'full'
  | 'partial'
  | 'none'
  | 'directional'

export const EQUIVALENCE_DEGREE_VALUES: EquivalenceDegree[] = [
  'full',
  'partial',
  'none',
  'directional',
];

export interface NonVerbalRep {
  /** Type of representation. */
  type?: ('image' | 'table' | 'formula');
  /** URI or path to the resource. */
  ref?: string;
  /** Alt text or description. */
  text?: string;
  /** Bibliographic source for the non-verbal representation. */
  sources?: ConceptSource[];
}

/**
 * Register or usage level of the designation (ISO 12620 / TBX-Linguist).
 */
export type Register =
  | 'colloquial_register'
  | 'neutral_register'
  | 'technical_register'
  | 'in_house_register'
  | 'bench_level_register'
  | 'slang_register'
  | 'vulgar_register'

export const REGISTER_VALUES: Register[] = [
  'colloquial_register',
  'neutral_register',
  'technical_register',
  'in_house_register',
  'bench_level_register',
  'slang_register',
  'vulgar_register',
];

/**
 * Part of speech classification of the designation.
 */
export type PartOfSpeech =
  | 'noun'
  | 'verb'
  | 'adj'
  | 'adverb'
  | 'preposition'
  | 'participle'

export const PART_OF_SPEECH_VALUES: PartOfSpeech[] = [
  'noun',
  'verb',
  'adj',
  'adverb',
  'preposition',
  'participle',
];

