# frozen_string_literal: true

module Glossarist
  module ConceptModel
    module Validators
      # CheckLutamlReferences — verifies every class referenced by a
      # LUTAML model file exists.
      #
      # Parses `+name: ClassName [cardinality]` declarations and
      # resolves `ClassName` against either:
      #   - a `.lutaml` file under models/, OR
      #   - the EXTERNAL_LUTAML_TYPES allowlist (stdlib + lutaml-model)
      class CheckLutamlReferences < Glossarist::ConceptModel::Validator
        REF_RE = /^\s*\+\w+:\s+(?:<<\w+>>\s+)?([A-Z][A-Za-z0-9_]*)\b/.freeze

        def run
          defined = model_class_names | Repo::EXTERNAL_LUTAML_TYPES.to_set
          broken = []

          Dir.glob("#{Repo::MODELS_DIR}/**/*.lutaml").sort.each do |path|
            File.read(path).scan(REF_RE).flatten.each do |ref|
              next if defined.include?(ref)
              rel = path.sub("#{Repo::ROOT}/", "")
              broken << "#{rel}: → #{ref}"
            end
          end

          if broken.empty?
            total = Dir.glob("#{Repo::MODELS_DIR}/**/*.lutaml").length
            ok("OK: scanned #{total} LUTAML files, all class references resolve")
          else
            fail_with("FAIL: #{broken.length} unresolved LUTAML class references", broken)
          end
        end

        private

        def model_class_names
          Dir.glob("#{Repo::MODELS_DIR}/**/*.lutaml")
            .map { |p| File.basename(p, ".lutaml") }
            .to_set
        end
      end
    end
  end
end
