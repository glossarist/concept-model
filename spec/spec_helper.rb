# frozen_string_literal: true

require "glossarist/concept_model"
require "rspec"
require "stringio"

# Each validator is invoked against the live repo. Tests assert exit
# codes and stdout/stderr content. No doubles — real model instances
# and real files throughout.
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec
  config.order = :random
  Kernel.srand config.seed
end

# Helper: run a validator and capture stdout/stderr/exit code.
# Captures by reassigning $stdout / $stderr — no mocks of framework
# methods. The validator instance is the real object (no double).
def run_validator(klass)
  stdout = StringIO.new
  stderr = StringIO.new
  original_out = $stdout
  original_err = $stderr
  $stdout = stdout
  $stderr = stderr
  exit_code = klass.new.call
  [exit_code, stdout.string, stderr.string]
ensure
  $stdout = original_out
  $stderr = original_err
end

def stderr_message(stream)
  "stream was:\n#{stream}"
end
