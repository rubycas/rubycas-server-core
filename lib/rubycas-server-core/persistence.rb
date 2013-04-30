require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

require_relative 'persistence/adapter'

module RubyCAS::Server::Core
  module Persistence
    class AdapterNotRegisteredError < StandardError; end
    class AdapterNotSpecifiedError < StandardError; end

    class << self
      attr_reader :adapter
    end

    @adapters ||= HashWithIndifferentAccess.new

    def self.setup(config)
      adapter_name = config.fetch(:adapter) {
        raise AdapterNotSpecifiedError.new("No adapter specified in config file!")
      }
      adapter_class = adapter_named(adapter_name)
      @adapter = adapter_class.setup(config)
    end

    def self.register_adapter(adapter_name, handler)
      @adapters[adapter_name] = handler
    end

    def self.adapter_named(name)
      @adapters.fetch(name) {
        raise AdapterNotRegisteredError.new("No persistence adapter named #{name} has been registered, avaliable adapters are: #{@adapters.keys.join(', ')}")
      }
    end

    def self.save_ticket(ticket)
      adapter.save_ticket(ticket)
    end

    def self.load_login_ticket(lt_string)
    end

    def self.load_ticket_granting_ticket(tgt_string)
    end

    def self.load_service_ticket(st_string)
    end
  end
end
