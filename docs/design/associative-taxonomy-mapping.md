# ISO 704:2022 §5.5.5 Table 1 → Glossarist `related_concept_type` mapping

ISO 704:2022 §5.5.5 Table 1 enumerates 8 types × ~30 subtypes of
associative relations. This document maps each to Glossarist's
`related_concept_type` enum value(s).

The Glossarist convention: each subtype gets **two** enum values
(directional and inverse), except for symmetric relations
(`opposite_of`, `compare`, `contrast`) which use a single bidirectional
value.

## 1. Contiguity relation (based on proximity between objects)

| ISO 704 subtype | Direction | Example | Glossarist enum |
|-----------------|-----------|---------|-----------------|
| enhancement (tool – accessory) | A → B | smartphone → selfie stick | `enhances` |
| | B → A | selfie stick → smartphone | `enhanced_by` |
| locative (container – contained) | A → B | milk carton → milk | `contains` |
| | B → A | milk → milk carton | `contained_by_container` |
| locative (contained – contained) | A → B | fish → shellfish (re: sea) | `contained_by_contained` |
| attachment (tool – connection) | A → B | screen → HDMI port | `attaches` |
| | B → A | HDMI port → screen | `attached_to` |
| material (concrete item – material) | A → B | seawater → salt | `made_of` |
| | B → A | salt → seawater | `material_of` |
| property (material – state) | A → B | air → humidity | `has_property` |
| | B → A | humidity → air | `property_of` |
| ownership (object – owner) | A → B | enterprise → state | `owned_by` |
| | B → A | state → enterprise | `owns` |
| rank (level – level) | A → B | chair → vice-chair | `ranks_above` |
| | B → A | vice-chair → chair | `ranks_below` |

## 2. Sequential relation (based on ordering criterion)

| ISO 704 subtype | Direction | Example | Glossarist enum |
|-----------------|-----------|---------|-----------------|
| temporal (earlier – later) | A → B | production → consumption | `precedes` (already in enum) |
| | B → A | consumption → production | `follows` (already in enum) |
| causal (cause – effect) | A → B | humidity → corrosion | `causes` |
| | B → A | corrosion → humidity | `caused_by` |
| spatial (in space) | A → B | floor → ceiling | `spatially_related` (already) |
| developmental (step – step) | A → B | tadpole → frog | `develops_into` |
| | B → A | frog → tadpole | `develops_from` |

## 3. Activity relation (based on action object)

| ISO 704 subtype | Direction | Example | Glossarist enum |
|-----------------|-----------|---------|-----------------|
| agent (action – actor) | A → B | energy conversion → energy | `performed_by` |
| | B → A | energy → energy conversion | `performs_action` |
| manner (action – method) | A → B | teach → e-learning | `done_by_method` |
| | B → A | e-learning → teach | `method_of` |
| locational (action – place) | A → B | teach → school | `done_at` |
| | B → A | school → teach | `place_of_action` |
| purpose (action – objective) | A → B | medical exam → diagnosis | `done_for_purpose` |
| | B → A | diagnosis → medical exam | `purpose_of_action` |
| result (action – beneficiary) | A → B | discharge → patient | `done_for_beneficiary` |
| | B → A | patient → discharge | `beneficiary_of_action` |
| object (action – object) | A → B | learn → school | `acts_on_object` |
| | B → A | school → learn | `object_of_action` |
| tool (action – instrument) | A → B | click → mouse | `done_with_tool` |
| | B → A | mouse → click | `tool_of_action` |
| patient (action – patient) | A → B | psychotherapy → client | `acts_on_patient` |
| | B → A | client → psychotherapy | `patient_of_action` |

## 4. Instrumental relation (based on tool used for purpose)

| ISO 704 subtype | Direction | Example | Glossarist enum |
|-----------------|-----------|---------|-----------------|
| originator (producer – product) | A → B | baker → bread | `produces` |
| | B → A | bread → baker | `produced_by` |
| ingredient (raw material – product) | A → B | wood → desk | `made_from_ingredient` |
| | B → A | desk → wood | `ingredient_of` |
| instrument-product (tool – product) | A → B | oven → bread | `produced_by_instrument` |
| | B → A | bread → oven | `instrument_product_of` |
| agent-instrument (professional – tool) | A → B | painter → brush | `employed_by_professional` |
| | B → A | brush → painter | `employs_tool` |
| object-instrument (object – tool for handling) | A → B | time → clock | `handled_by_tool` |
| | B → A | clock → time | `tool_handles` |
| instrument-patient (tool – patient) | A → B | baby sling → baby | `applied_to_patient` |
| | B → A | baby → baby sling | `patient_of_tool` |

## 5. Interactional relation (two-way connection)

| ISO 704 subtype | Direction | Example | Glossarist enum |
|-----------------|-----------|---------|-----------------|
| dependency (controlled – controller) | A → B | pointer → mouse | `controlled_by` |
| | B → A | mouse → pointer | `controls` |
| representational (entity – representative) | A → B | length → metre | `represented_by` |
| | B → A | metre → length | `represents` |

## 6. Origination relation

Single enum pair (alias of producer-product above):

| Direction | Example | Glossarist enum |
|-----------|---------|-----------------|
| A → B | producer → product | `originates_from` |
| B → A | product → producer | `origin_of` |

## 7. Transmission relation (sender-receiver)

| ISO 704 subtype | Direction | Example | Glossarist enum |
|-----------------|-----------|---------|-----------------|
| sender-receiver | A → B | satellite → dish | `sends_to` |
| | B → A | dish → satellite | `receives_from` |
| sender (sender – object) | A → B | phone → text message | `sends_object` |
| | B → A | text message → phone | `object_sent_by` |

## 8. Opposite relation (objects as opposites)

Bidirectional — single enum value:

| ISO 704 subtype | Example | Glossarist enum |
|-----------------|---------|-----------------|
| opposite | encoding – decoding | `opposite_of` |

## Notes

- Each directional value has a corresponding inverse for symmetry validators
- `compare` and `contrast` (ISO 10241-1 §3.4.1.5 antonym) are bidirectional, single-value
- ISO 12620 A.6.4 "associative relation" aliases (thematic, pragmatic) map to the same enum space
- Pre-existing values (`sequentially_related`, `spatially_related`, `temporally_related`, `references`, etc.) are retained for backward compatibility
