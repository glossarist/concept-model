# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    module Validators
      # CheckBibliographyNotConceptIds — warns when a BibliographyEntry.id
      # matches a concept id in the same dataset. Bibliography entries
      # should be pure bibliographic records (papers, external standards),
      # NOT concepts. If the referenced thing IS a concept, it should be
      # a ConceptSource with structured origin.ref instead.
      class CheckBibliographyNotConceptIds < Glossarist::ConceptModel::Validator
        def run
          warnings = []
          concept_ids = collect_concept_ids

          each_bibliography_entry do |path, entry_id|
            if concept_ids.include?(entry_id)
              warnings << "#{relative(path)}: bibliography entry '#{entry_id}' matches a concept ID " \
                          "in the same dataset — consider using ConceptSource instead"
            end
          end

          warnings.each { |w| $stderr.puts "WARN: #{w}" }
          ok("OK: bibliography-vs-concept-ID check complete (#{warnings.length} warnings)")
        end

        private

        def collect_concept_ids
          ids = Set.new
          Dir.glob("#{Repo::EXAMPLES_DIR}/*.yaml").sort.each do |path|
            YAML.load_stream(File.read(path)).each do |doc|
              next unless doc.is_a?(Hash)
              id = doc["id"] || doc.dig("data", "identifier")
              ids << id.to_s if id
            end
          end
          ids
        end

        def each_bibliography_entry
          bib_path = Repo::EXAMPLES_DIR / "bibliography.yaml"
          return unless bib_path.exist?

          doc = YAML.load_file(bib_path)
          return unless doc.is_a?(Hash) && doc["bibliography"]

          doc["bibliography"].each do |entry|
            next unless entry.is_a?(Hash) && entry["id"]
            yield bib_path, entry["id"]
          end
        end

        def relative(path)
          path.relative_path_from(Repo::ROOT)
        end
      end
    end
  end
end
