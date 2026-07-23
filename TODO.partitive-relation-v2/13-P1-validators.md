# 13 — P1: New validators

## Problem

v2 introduces validation concerns that v1 didn't have:

1. **Criterion coherence**: a comprehensive with two
   PartitiveRelations and identical criterion is a duplicate
   decomposition (error)
2. **Criterion documentation**: a comprehensive with multiple
   PartitiveRelations where any lacks criterion is a warning
   (can't verify distinctness)
3. **ExternalConcept shape**: an external concept with a definition
   contradicts itself (error)
4. **Per-relation cardinality**: each relation needs ≥2 partitives
   (ISO requirement); already checked at SHACL level but a Ruby
   validator gives clearer error messages
5. **Plurality coherence**: a TypeSharedPlurality with
   `is_uncertain: true` but `is_shared: false` is semantically odd
   (broken line qualifies the close-set double line plurality;
   without `double`, what's being qualified?) — warning

## Scope

- New: `lib/glossarist/concept_model/validators/check_partitive_relation_coherence.rb`
- New: `lib/glossarist/concept_model/validators/check_external_concept_shape.rb`
- New: `exe/check-partitive-relation-coherence`
- New: `exe/check-external-concept-shape`
- Update: `Makefile` (add to validate target)
- Update: `.github/workflows/validate-schemas.yml`
- Update: `spec/validators/` (new specs)

## Concrete validators

### CheckPartitiveRelationCoherence

```ruby
# lib/glossarist/concept_model/validators/check_partitive_relation_coherence.rb
module Glossarist
  module ConceptModel
    module Validators
      class CheckPartitiveRelationCoherence < Validator
        def run
          failures = []
          warnings = []

          each_concept_yaml do |path, docs|
            doc = docs.first
            next unless doc.is_a?(Hash)
            relations = doc.dig("partitive_relations") || []
            next if relations.empty?

            # Check 1: each relation has ≥2 partitives
            relations.each_with_index do |rel, i|
              count = (rel["partitives"] || []).length
              next if count >= 2
              failures << "#{path}: relation #{i} has #{count} partitives (ISO requires ≥2)"
            end

            # Check 2: no duplicate (comprehensive + criterion)
            seen = {}
            relations.each_with_index do |rel, i|
              comp = rel["comprehensive"]&.then { |c| "#{c['source']}:#{c['id']}" }
              crit = rel["criterion"]&.then { |c| c.values.sort.join("|") }
              next unless comp && crit
              key = "#{comp}|#{crit}"
              if seen[key]
                failures << "#{path}: relations #{seen[key]} and #{i} are duplicates (same comprehensive + same criterion)"
              else
                seen[key] = i
              end
            end

            # Check 3: warn if any relation lacks criterion when there are 2+
            if relations.length > 1
              relations.each_with_index do |rel, i|
                next if rel["criterion"]
                warnings << "#{path}: relation #{i} has no criterion; cannot verify distinctness from siblings"
              end
            end

            # Check 4: warn about plurality incoherence
            relations.each_with_index do |rel, i|
              plural = rel["plurality"]
              next unless plural
              if plural["is_uncertain"] && !plural["is_shared"]
                warnings << "#{path}: relation #{i} plurality has is_uncertain=true without is_shared=true (semantically odd)"
              end
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          if failures.empty?
            ok("OK: all PartitiveRelations coherent (#{warnings.length} warnings)")
          else
            fail_with("FAIL: #{failures.length} coherence issue(s)", failures)
          end
        end

        private

        def each_concept_yaml
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            yield path, YAML.load_stream(File.read(path))
          end
        end
      end
    end
  end
end
```

### CheckExternalConceptShape

```ruby
# lib/glossarist/concept_model/validators/check_external_concept_shape.rb
module Glossarist
  module ConceptModel
    module Validators
      class CheckExternalConceptShape < Validator
        def run
          failures = []

          each_concept_yaml do |path, docs|
            doc = docs.first
            next unless doc.is_a?(Hash)
            next unless doc["status"] == "external"

            data = doc["data"] || {}

            # External concepts must NOT have a definition
            if data["definition"] && !data["definition"].empty?
              failures << "#{path}: external concept has a definition (contradicts status: external)"
            end

            # External concepts must NOT have sources
            if data["sources"] && !data["sources"].empty?
              failures << "#{path}: external concept has sources (contradicts status: external)"
            end

            # External concepts MUST have at least one designation
            designations = data["designations"] || []
            if designations.empty?
              failures << "#{path}: external concept has no designations (need at least one name)"
            end
          end

          if failures.empty?
            ok("OK: all ExternalConcepts are well-formed")
          else
            fail_with("FAIL: #{failures.length} ExternalConcept shape issue(s)", failures)
          end
        end

        private

        def each_concept_yaml
          Dir.glob("#{Repo::EXAMPLES_DIR}/**/*.yaml").sort.each do |path|
            yield path, YAML.load_stream(File.read(path))
          end
        end
      end
    end
  end
end
```

## Verification

```bash
bundle exec exe/check-partitive-relation-coherence
bundle exec exe/check-external-concept-shape

# Specs
bundle exec rspec spec/validators/check_partitive_relation_coherence_spec.rb
bundle exec rspec spec/validators/check_external_concept_shape_spec.rb

# Integrated into make validate
make validate
```

## CI integration

Update `.github/workflows/validate-schemas.yml`:

```yaml
  check-partitive-relation-coherence:
    name: Check PartitiveRelation coherence (criterion, cardinality)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { ruby-version: '3.4', bundler-cache: true }
      - run: bundle exec exe/check-partitive-relation-coherence

  check-external-concept-shape:
    name: Check ExternalConcept shape (no definition, has designation)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { ruby-version: '3.4', bundler-cache: true }
      - run: bundle exec exe/check-external-concept-shape
```

## Status: pending
