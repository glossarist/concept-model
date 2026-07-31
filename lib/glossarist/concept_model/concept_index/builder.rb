# frozen_string_literal: true

require "yaml"

module Glossarist
  module ConceptModel
    class ConceptIndex
      # Builder — constructs a ConceptIndex by scanning the examples
      # directory once. Separated from ConceptIndex to keep the index
      # itself a pure read-only data structure.
      class Builder
        def initialize(examples_dir)
          @examples_dir = examples_dir
        end

        def build
          index = ConceptIndex.new(examples_dir: @examples_dir)
          build_concepts(index)
          build_relations(index)
          index
        end

        private

        def build_concepts(index)
          Dir.glob("#{@examples_dir}/*.yaml").sort.each do |path|
            pathname = Pathname.new(path)
            YAML.load_stream(File.read(path)).each do |doc|
              index.add_concept(pathname, doc)
            end
          end
        end

        def build_relations(index)
          relations_dir = @examples_dir / "relations"
          return unless relations_dir.exist?

          Dir.glob("#{relations_dir}/**/*.yaml").sort.each do |path|
            pathname = Pathname.new(path)
            doc = YAML.load_file(path)
            index.add_relation(pathname, doc)
          end
        end
      end
    end
  end
end
