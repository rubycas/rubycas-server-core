require 'rubygems'
require 'bundler/setup'
begin
  require 'debugger'
rescue LoadError
  puts 'Debugger not found! testing on CI?'
end
require 'ostruct'
require 'rubycas-server-core'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
