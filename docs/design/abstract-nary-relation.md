# AbstractNaryRelation + ConceptSystemMember — Refactor

## Status

Proposed — 2026-07-29. Implementation: TODO.general-rels.

## Why an abstract base now

With one n-ary leaf (Partitive), an abstract base was premature. With
two leaves (Partitive + Generic), the shared shape is real:

**Member side:** both PartitiveMember and GenericMember carry the same
MECE dimensions:
- `ref` (ConceptRef)
- `presence` (required | optional)
- `count` (exactly_one | at_least_one | multiple)
- `is_delimiting` (Boolean)

**Relation side:** both PartitiveRelation and GenericRelation carry:
- `comprehensive` (ConceptRef)
- `members` (ConceptSystemMember[2..*])
- `completeness` (complete | partial)
- `criterion` (LocalizedString)
- `sources` (ConceptSource[])
- `notes` (LocalizedString)
- `status` (ConceptStatus)

The abstract base eliminates duplication. Adding AssociativeRelation
later (with a `role` field on members) is one new leaf, not a refactor.

## LUTAML

LUTAML files do not declare explicit inheritance. Each leaf class
declares its own fields. The abstract base is conceptual — documented
in the leaf's `definition {}` block as "mirrors ConceptSystemMember"
or "mirrors AbstractNaryRelation shape."

Concrete:
- `models/concepts/ConceptSystemMember.lutaml` — the canonical shape
- `models/concepts/PartitiveMember.lutaml` — same fields, Partitive-specific docs
- `models/concepts/GenericMember.lutaml` — same fields, Generic-specific docs

Same for relations:
- `models/concepts/AbstractNaryRelation.lutaml` — the canonical shape
  (documentation only; not a leaf)
- `models/concepts/PartitiveRelation.lutaml` — leaf with Partitive docs
- `models/concepts/GenericRelation.lutaml` — leaf with Generic docs

## Ruby

Regular Ruby inheritance. The abstract base is a real class:

```ruby
class ConceptSystemMember < Lutaml::Model::Serializable
  attribute :ref, ConceptRef
  attribute :presence, :string, values: Presence::VALUES
  attribute :count, :string, values: Count::VALUES
  attribute :is_delimiting, :boolean, default: false
  # key_value mapping...
end

class PartitiveMember < ConceptSystemMember; end
class GenericMember < ConceptSystemMember; end
```

```ruby
class AbstractNaryRelation < Lutaml::Model::Serializable
  attribute :comprehensive, ConceptRef
  attribute :members, ConceptSystemMember, collection: true  # overridden in leaves
  attribute :completeness, :string, values: ..., default: -> { "complete" }
  attribute :criterion, :hash
  attribute :sources, ConceptSource, collection: true
  attribute :notes, :hash
  attribute :status, :string, values: ...

  def validate! ... end
  def complete? ... end
  def partial? ... end
  def coordinate? ... end
end

class PartitiveRelation < AbstractNaryRelation
  attribute :members, PartitiveMember, collection: true
end

class GenericRelation < AbstractNaryRelation
  attribute :members, GenericMember, collection: true
end
```

The leaf overrides `members` to specify the typed member class.
Shared validations live in the abstract base.

## Wire format

The `type` field discriminates on the wire:

```yaml
type: partitive_relation   # or generic_relation
```

Both share all other field names. No type-specific wire differences.

## JSON Schema

```yaml
$defs:
  concept_system_member:
    # shared MECE shape with allOf/if-then constraint
    type: object
    properties: { ref, presence, count, is_delimiting }
    required: [ref]
    not: { allOf: [...] }   # the (optional + at_least_one) rejection
```

Each leaf `$defs/partitive_member` and `$defs/generic_member` is a
`$ref` to `concept_system_member`. They share the shape; type safety
lives in code (Ruby/TS) not in schema.

## SHACL

A shared `gloss:ConceptSystemMemberShape` declares the MECE constraints.
`PartitiveMemberShape` and `GenericMemberShape` are `sh:node` references
to the shared shape, plus type assertion (`sh:class gloss:PartitiveMember`).

## Validators

A shared module `NaryCoherence` provides the cardinality/criterion/MECE
checks. Each leaf validator (CheckPartitiveRelationCoherence,
CheckGenericRelationCoherence) mixes in the module and supplies the
type label for error messages.

## Why not collapse into one class

Three reasons to keep distinct leaves:

1. **Type safety in code:** Ruby/TS code can dispatch on type. A
   function expecting PartitiveRelation should reject GenericRelation.
2. **Future divergence:** AssociativeMember gains a `role` field;
   SequentialMember might gain a `position` field. The leaf pattern
   accommodates this without touching the abstract.
3. **Documentation:** ISO 704 treats these as distinct relation types
   with distinct semantics. The class hierarchy mirrors the standard.

## Cross-references

- [Generic Relation Design](generic-relation.md)
- [Relations as Files](relations-as-files.md)
