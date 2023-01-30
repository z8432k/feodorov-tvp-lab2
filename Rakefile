# frozen_string_literal: true

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  warn "RSpec rake tasks was not loaded"
end

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  warn "Rubocop rake tasks was not loaded"
end

task default: %i[spec]
