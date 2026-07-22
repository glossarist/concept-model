# frozen_string_literal: true

require "rdf/turtle"

module Glossarist
  module ConceptModel
    module Validators
      # ValidateOntologies — two passes:
      #   1. Per-file Turtle parse — every .ttl must parse.
      #   2. Cross-file sh:targetClass integrity — every sh:targetClass
      #      gloss:X must resolve to an owl:Class gloss:X somewhere.
      class ValidateOntologies < Glossarist::ConceptModel::Validator
        GLOSS_PREFIX = "https://www.glossarist.org/ontologies/".freeze
        SHACL_TARGET_CLASS = RDF::URI("http://www.w3.org/ns/shacl#targetClass").freeze

        def run
          ttl_files = Dir.glob("#{Repo::ONTOLOGIES_DIR}/**/*.ttl").sort

          parse_failures = parse_each(ttl_files)
          cross_failures = cross_check_target_classes(ttl_files)

          details = []
          unless parse_failures.empty?
            details << "Parse errors:"
            details.concat(parse_failures.map { |p, e| "  #{p}: #{e}" })
          end
          unless cross_failures.empty?
            details << "Cross-reference errors:"
            details.concat(cross_failures.map { |e| "  #{e}" })
          end

          if details.empty?
            ok("OK: #{ttl_files.length} Turtle files parse, all sh:targetClass resolve")
          else
            fail_with("FAIL: #{parse_failures.length + cross_failures.length} ontology errors", details)
          end
        end

        private

        def parse_each(ttl_files)
          failures = []
          ttl_files.each do |path|
            repo = RDF::Repository.new
            RDF::Reader.open(path) { |r| r.each_statement { |s| repo << s } }
          rescue => e
            failures << [path, e.message]
          end
          failures
        end

        def cross_check_target_classes(ttl_files)
          merged = RDF::Repository.new
          ttl_files.each do |path|
            RDF::Reader.open(path) { |r| r.each_statement { |s| merged << s } }
          end

          defined_classes = merged
            .query([nil, RDF.type, RDF::URI("http://www.w3.org/2002/07/owl#Class")])
            .map(&:subject).to_set

          failures = []
          merged.query([nil, SHACL_TARGET_CLASS, nil]).each do |stmt|
            target = stmt.object
            next unless target.to_s.start_with?(GLOSS_PREFIX)
            next if defined_classes.include?(target)
            failures << "sh:targetClass points at undefined class: #{target}"
          end
          failures
        end
      end
    end
  end
end
