# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckExternalAsComprehensive — warns when an n-ary relation uses
      # an ExternalConcept (status: external) as its comprehensive but
      # that ExternalConcept has no provided_by edge.
      #
      # Without provided_by, the decomposition dangles — readers can
      # see the rake structure but cannot resolve what the comprehensive
      # actually refers to.
      class CheckExternalAsComprehensive < Glossarist::ConceptModel::Validator
        def run
          warnings = []
          external_concepts = load_external_concepts

          each_relation_with_external_comprehensive do |path, comp_id|
            ext = external_concepts[comp_id]
            if ext.nil?
              warnings << "#{relative(path)}: comprehensive #{comp_id} looks external but no matching ExternalConcept file"
            elsif ext && !ext[:has_provided_by]
              warnings << "#{relative(path)}: comprehensive #{comp_id} is an ExternalConcept without provided_by edge (resolution dangles)"
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }

          ok("OK: ExternalConcept-as-comprehensive check complete (#{warnings.length} warnings)")
        end

        private

        def load_external_concepts
          {}.tap do |h|
            Dir.glob("#{Repo::EXAMPLES_DIR}/**/*.yaml").sort.each do |path|
              YAML.load_stream(File.read(path)).each do |doc|
                next unless doc.is_a?(Hash)
                next unless doc["status"] == "external"

                identifier = doc.dig("data", "identifier") || doc["id"]
                next unless identifier

                related = doc["related"] || []
                has_provided_by = related.any? { |r| r.is_a?(Hash) && r["type"] == "provided_by" }
                h[identifier.to_s] = { path: path, has_provided_by: has_provided_by }
              end
            end
          end
        end

        def each_relation_with_external_comprehensive
          relations_dir = Repo::EXAMPLES_DIR / "relations"
          return unless relations_dir.exist?

          Dir.glob("#{relations_dir}/**/*.yaml").sort.each do |path|
            doc = YAML.load_file(path)
            next unless doc.is_a?(Hash)

            comp = doc["comprehensive"] || {}
            next unless comp["text"] || looks_external?(comp)

            yield Pathname.new(path), comp["id"].to_s
          end
        end

        # An ExternalConcept comprehensive often carries a `text` field
        # with the placeholder label, OR an id prefixed with `ext-`.
        def looks_external?(concept_ref)
          return false unless concept_ref.is_a?(Hash)
          id = concept_ref["id"].to_s
          id.start_with?("ext-") || id.start_with?("(") || concept_ref["text"].to_s.start_with?("(")
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
