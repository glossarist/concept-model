# frozen_string_literal: true

require "rdf/turtle"
require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckEnumDrift — detects enum drift across four declaration sites:
      #
      #   1. schemas/v3/concept.yaml $defs/<name> with `enum:` block
      #   2. SHACL sh:valuesFrom <scheme> URI
      #   3. SKOS ConceptScheme in ontologies/taxonomies/*.ttl
      #   4. LUTAML `enum X { ... }` declarations in models/**/*.lutaml
      #
      # Pairing convention: camelCase ConceptScheme local name maps
      # to snake_case schema $def name (e.g. `partitiveEnumeration`
      # ↔ `completeness`).
      class CheckEnumDrift < Glossarist::ConceptModel::Validator
        ENUM_RE           = /^\s*enum\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{(.*?)^\}/m.freeze
        MEMBER_RE         = /^[ \t]*([a-z][a-zA-Z0-9_-]*)\s*\{/.freeze
        NON_MEMBERS       = %w[definition].freeze
        SKOS_NS           = "http://www.w3.org/2004/02/skos/core#".freeze
        SKOS_CONCEPT_SCHEME = RDF::URI("#{SKOS_NS}ConceptScheme").freeze
        SKOS_IN_SCHEME    = RDF::URI("#{SKOS_NS}inScheme").freeze
        SKOS_PREF_LABEL   = RDF::URI("#{SKOS_NS}prefLabel").freeze
        SHACL_VALUES_FROM = RDF::URI("http://www.w3.org/ns/shacl#valuesFrom").freeze

        def run
          schema      = YAML.load_file(Repo::CONCEPT_SCHEMA)
          schema_map  = schema_enums(schema)
          tax_graph   = load_taxonomy_graph
          tax_schemes = taxonomy_schemes(tax_graph)
          shacl_graph = load_graph(Repo::SHACL.to_s)
          shacl_uris  = shacl_valuesfrom_uris(shacl_graph)
          lutaml_map  = lutaml_enums

          failures = []

          shacl_uris.sort.each do |uri|
            failures << "SHACL sh:valuesFrom target does not exist as a skos:ConceptScheme: #{uri}" \
              unless tax_schemes.key?(uri)
          end

          tax_schemes.each do |uri, values|
            snake = camel_to_snake(uri.sub(%r{.*/}, ""))
            next unless schema_map.key?(snake)
            if schema_map[snake] != values
              failures << "DRIFT schema vs taxonomy for '#{snake}': " \
                          "schema=#{schema_map[snake].sort.inspect} " \
                          "taxonomy=#{values.sort.inspect}"
            end
          end

          lutaml_map.each do |enum_name, members|
            snake = camel_to_snake(enum_name)
            next unless schema_map.key?(snake)
            if schema_map[snake] != members
              failures << "DRIFT schema vs LUTAML for '#{enum_name}' (#{snake}): " \
                          "schema=#{schema_map[snake].sort.inspect} " \
                          "lutaml=#{members.sort.inspect}"
            end
          end

          if failures.empty?
            ok("OK: #{tax_schemes.length} taxonomies, #{schema_map.length} schema enums, " \
               "#{shacl_uris.length} SHACL refs, #{lutaml_map.length} LUTAML enums — all consistent")
          else
            fail_with("FAIL: #{failures.length} drift issue(s)", failures)
          end
        end

        private

        def schema_enums(schema)
          out = {}
          (schema["$defs"] || {}).each do |name, defn|
            next unless defn.is_a?(Hash) && defn.key?("enum")
            out[name] = defn["enum"].to_set
          end
          out
        end

        def load_graph(path)
          repo = RDF::Repository.new
          RDF::Reader.open(path) { |r| r.each_statement { |s| repo << s } }
          repo
        end

        def load_taxonomy_graph
          repo = RDF::Repository.new
          Dir.glob("#{Repo::TAXONOMIES_DIR}/*.ttl").sort.each do |f|
            RDF::Reader.open(f) { |r| r.each_statement { |s| repo << s } }
          end
          repo
        end

        def taxonomy_schemes(graph)
          out = {}
          graph.query([nil, RDF.type, SKOS_CONCEPT_SCHEME]).each do |soln|
            scheme = soln.subject
            values = graph.query([nil, SKOS_IN_SCHEME, scheme]).map do |s|
              label_stmt = graph.query([s.subject, SKOS_PREF_LABEL, nil]).first
              label_stmt&.object&.to_s
            end.compact.to_set
            out[scheme.to_s] = values
          end
          out
        end

        def shacl_valuesfrom_uris(graph)
          graph.query([nil, SHACL_VALUES_FROM, nil]).map(&:object).map(&:to_s).to_set
        end

        def lutaml_enums
          out = {}
          Dir.glob("#{Repo::MODELS_DIR}/**/*.lutaml").sort.each do |path|
            text = File.read(path)
            text.scan(ENUM_RE).each do |name, body|
              members = body.scan(MEMBER_RE).flatten
                                  .reject { |m| NON_MEMBERS.include?(m) }
                                  .map { |m| normalize_member(m) }
                                  .to_set
              out[name] = members
            end
          end
          out
        end

        def camel_to_snake(name)
          name.gsub(/(?<!^)(?=[A-Z])/, "_").downcase
        end

        def normalize_member(name)
          name.gsub(/(?<!^)(?=[A-Z])/, "_").gsub("-", "_").downcase
        end
      end
    end
  end
end
