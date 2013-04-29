module RubyCAS::Server::Core
  module Persistence
    class AdapterNotRegisteredError < StandardError; end

    @adapters ||= HashWithIndifferentAccess.new

    def self.register_adapter(adapter_name, handler)
      @adapters[adapter_name] = handler
    end

    def self.adapter_named(name)
      @adapters.fetch(name) {
        raise AdapterNotRegisteredError.new("No persistence adapter named #{name} has been registered, avaliable adapters are: #{@adapters.keys.join(', ')}")
      }
    end

    def self.load_ticket_granting_ticket(tgt_string)
      raise NotImplementedError.new('This should be overridden by your adapter of choice')
    end
  end
end
