# frozen_string_literal: true

module Glossarist
  module ConceptModel
    # Multiplicity — utility for mapping between the MECE (presence, count)
    # pair and the ISO 704:2022 flat-enum name.
    #
    # The MECE pair is the canonical wire form. The flat-enum name is a
    # display concern — consumers that need to show "compulsory" instead
    # of "(required, exactly_one)" should call `from_pair`.
    #
    # The inverse direction (`to_pair`) is used by the migration script
    # to map old flat-enum data to the MECE pair.
    module Multiplicity
      MAPPING = {
        ["required", "exactly_one"]  => "compulsory",
        ["optional", "exactly_one"]  => "optional",
        ["required", "multiple"]     => "compulsory_multiple",
        ["optional", "multiple"]     => "optional_multiple",
        ["required", "at_least_one"] => "compulsory_at_least_one",
      }.freeze

      INVERSE = MAPPING.to_a.to_h { |name, pair| [pair, name] }.freeze

      class << self
        def from_pair(presence, count)
          MAPPING.fetch([presence, count]) do
            raise ArgumentError,
                  "invalid (presence, count) pair: (#{presence.inspect}, #{count.inspect})"
          end
        end

        def to_pair(name)
          INVERSE.fetch(name) do
            raise ArgumentError, "unknown multiplicity name: #{name.inspect}"
          end
        end

        def invalid_pair?(presence, count)
          presence == "optional" && count == "at_least_one"
        end

        def valid_pair?(presence, count)
          MAPPING.key?([presence, count])
        end
      end
    end
  end
end
