# frozen_string_literal: true

module Glossarist
  module ConceptModel
    # Validator — base class for every check-*.rb / validate-*.rb script.
    #
    # Subclasses implement #run, returning a Result. The base class
    # handles stdout/stderr formatting and exit-code conversion.
    #
    # Use:
    #   class MyCheck < Validator
    #     def run
    #       if everything_ok
    #         ok("all good")
    #       else
    #         fail_with("found problems", %w[thing1 thing2])
    #       end
    #     end
    #   end
    #
    #   exit MyCheck.call   # call from an exe shim
    class Validator
      Result = Struct.new(:success, :message, :details, keyword_init: true) do
        def success? = success
      end

      def self.call(...)
        new(...).call
      end

      # Entry point — runs #run, prints the result, returns exit code.
      def call
        result = run
        if result.success?
          $stdout.puts result.message
          0
        else
          $stderr.puts result.message
          Array(result.details).each { |line| $stderr.puts "  #{line}" }
          1
        end
      rescue => e
        $stderr.puts "ERROR: #{e.class}: #{e.message}"
        $stderr.puts e.backtrace.first(5).join("\n") if ENV["DEBUG"]
        2
      end

      # Subclasses must override.
      def run
        raise NotImplementedError, "#{self.class} must implement #run"
      end

      protected

      def ok(message, details = [])
        Result.new(success: true, message: message, details: details)
      end

      def fail_with(message, details = [])
        Result.new(success: false, message: message, details: details)
      end
    end
  end
end
