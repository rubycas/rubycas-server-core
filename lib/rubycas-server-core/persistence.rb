require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

require_relative 'persistence/adapter'

module RubyCAS::Server::Core
  module Persistence
    class AdapterNotRegisteredError < StandardError; end
    class AdapterNotSpecifiedError < StandardError; end

    attr_reader :adapter
    @adapters ||= HashWithIndifferentAccess.new

    delegate :load_login_ticket, :load_ticket_granting_ticket, :load_service_ticket,
             :save_login_ticket, :save_ticket_granting_ticket, :save_service_ticket,
             to: :adapter

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
  end
end
