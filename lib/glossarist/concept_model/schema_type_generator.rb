# frozen_string_literal: true

require "optparse"
require "yaml"
require "pathname"

module Glossarist
  module ConceptModel
    # SchemaTypeGenerator — emits TypeScript interfaces / type aliases /
    # const arrays from JSON Schemas. Single source of truth (schemas)
    # → typed output for downstream TS consumers.
    #
    # See exe/generate-types-from-schemas for the CLI entry point.
    class SchemaTypeGenerator
      SCHEMAS_DIR = Pathname.new("schemas/v3")
      OUTPUT_DIR  = SCHEMAS_DIR / "types"

      SCHEMA_FILES = %w[
        concept.yaml
        relation.yaml
        localized-concept.yaml
        concept-system.yaml
      ].freeze

      def initialize(check_mode: false)
        @check_mode = check_mode
      end

      def run
        OUTPUT_DIR.mkpath
        SCHEMA_FILES.each { |f| emit_one(f) }
        emit_index
        if @check_mode
          fail_if_drift
        else
          puts "OK: TypeScript types generated under #{OUTPUT_DIR}"
        end
        0
      end

      private

      def emit_one(filename)
        schema = YAML.load_file(SCHEMAS_DIR / filename)
        basename = filename.sub(/\.yaml$/, "")
        out = render_header(filename) + render_schema(schema)
        write_output("#{basename}.ts", out)
      end

      def render_header(source_filename)
        <<~TS
          // AUTO-GENERATED from schemas/v3/#{source_filename} by exe/generate-types-from-schemas.
          // DO NOT EDIT by hand. Edit the schema, then re-run the generator.

        TS
      end

      def render_schema(schema)
        out = +""
        defs = schema["$defs"] || {}
        defs.each do |name, defn|
          out << render_def(name, defn)
        end
        out
      end

      def render_def(name, defn)
        type = defn["type"]
        if defn["enum"]
          return render_enum(pascal(name), defn["enum"], defn["description"])
        end

        case type
        when "object"
          render_interface(pascal(name), defn)
        when "string"
          "// #{name}: string alias\n\n"
        when "integer", "number"
          "// #{name}: number alias\n\n"
        else
          ""
        end
      end

      def render_enum(name, values, description)
        out = +""
        if description
          out << "/**\n"
          out << " * #{wrap_comment(description)}\n"
          out << " */\n"
        end
        out << "export type #{name} =\n"
        values.each do |v|
          out << "  | '#{v}'\n"
        end
        out << "\n"
        const_name = name.gsub(/([a-z])([A-Z])/, '\1_\2').upcase
        out << "export const #{const_name}_VALUES: #{name}[] = [\n"
        values.each do |v|
          out << "  '#{v}',\n"
        end
        out << "];\n\n"
        out
      end

      def render_interface(name, defn)
        props = defn["properties"] || {}
        required = defn["required"] || []
        out = "export interface #{name} {\n"
        props.each do |prop_name, prop_defn|
          optional = required.include?(prop_name) ? "" : "?"
          type_str = render_type_ref(prop_defn)
          description = prop_defn["description"]
          if description
            out << "  /** #{wrap_comment(description.split('\n').first)} */\n"
          end
          out << "  #{prop_name}#{optional}: #{type_str};\n"
        end
        out << "}\n\n"
        out
      end

      def render_type_ref(prop_defn)
        if prop_defn["$ref"]
          ref = prop_defn["$ref"].sub("#/$defs/", "").sub("concept.yaml#/$defs/", "")
          return pascal(ref)
        end

        case prop_defn["type"]
        when "string"
          prop_defn["enum"] ? "(#{prop_defn['enum'].map { |v| "'#{v}'" }.join(' | ')})" : "string"
        when "integer", "number"
          "number"
        when "boolean"
          "boolean"
        when "array"
          inner = render_type_ref(prop_defn["items"] || {})
          "#{inner}[]"
        when "object"
          "Record<string, string>"
        else
          "any"
        end
      end

      def write_output(name, content)
        path = OUTPUT_DIR / name
        if @check_mode
          existing = path.exist? ? path.read : ""
          if existing != content
            $stderr.puts "FAIL: #{path} drifts from schema"
            exit 1
          end
        else
          path.write(content)
        end
      end

      def emit_index
        names = SCHEMA_FILES.map { |f| f.sub(/\.yaml$/, "") }
        out = render_header("index.ts (barrel export)") + "\n"
        names.each do |n|
          out << "export * from './#{n}';\n"
        end
        write_output("index.ts", out)
      end

      def fail_if_drift
        puts "OK: TypeScript types are fresh"
      end

      def pascal(name)
        name.split(/[_-]/).map(&:capitalize).join
      end

      def wrap_comment(text)
        text.to_s.gsub(/\*\//, "*\\/").split("\n").join(" ")
      end
    end
  end
end
