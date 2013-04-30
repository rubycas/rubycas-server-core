require 'rubygems'
require 'bundler/setup'
require 'rubycas-server-core'
require 'rubycas-server-core/persistence/in_memory'
begin
  require 'debugger'
rescue LoadError
  puts "Debugger couldn't be loaded, running in CI?"
end
Bundler.require(:test)

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
