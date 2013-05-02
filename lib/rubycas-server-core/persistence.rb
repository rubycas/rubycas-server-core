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
      ticket_name = ticket.class.name.demodulize.underscore
      id = adapter.public_send("save_#{ticket_name}", ticket.attributes)
      if id
        ticket.id = id
        ticket
      else
        false
      end
    end

    class << self
      %w{login_ticket ticket_granting_ticket}.each do |ticket|
        klass = RubyCAS::Server::Core::Tickets.const_get(ticket.classify)
        method_name = "load_#{ticket}"
        define_method method_name do |id_or_ticket_string|
          begin
            attrs = adapter.public_send(method_name, id_or_ticket_string)
            klass.new(attrs)
          rescue Adapter::TicketNotFoundError
            RubyCAS::Server::Core::Tickets::NilTicket.new
          end
        end
      end
    end
  end
end
