module RubyCAS::Server::Core
  module Persistence
    # raised when an adapter is requested by a name that's unknown to the registry
    class AdapterNotRegisteredError < StandardError; end

    # raised in the setup method if no adapter is specified in the config file
    class AdapterNotSpecifiedError < StandardError; end

    class << self
      attr_reader :adapter
    end

    @adapters ||= {}

    # Configures our Persistence layer
    #
    # @param config [Hash] a hash of values for selecting our adapter and passing configuration values to it
    def self.setup(config)
      adapter_name = config.fetch(:adapter) {
        raise AdapterNotSpecifiedError.new("No adapter specified in config file!")
      }
      adapter_class = adapter_named(adapter_name)
      @adapter = adapter_class.setup(config)
    end

    # Adds an adapter class/module to the registry
    #
    # @param adapter_name [Symbol, String] the name we'll find this adapter by later
    # @param handler [Adapter] Anything that quacks like an adapter should do just fine here
    def self.register_adapter(adapter_name, handler)
      @adapters[adapter_name.to_s] = handler
    end

    # Find a registered adapter class by name
    #
    # @param name [String, Symbol] the name the adapter we're looking for was registered as
    # @return (Adapter) Most likely a subclass of our Adapter class but really could be anything that quacks right
    # @raise [AdapterNotRegisteredError] Will raise an error if the requested adapter can't be found
    #   should only happen on setup since that's the only place we should be querying for these
    def self.adapter_named(name)
      @adapters.fetch(name.to_s) {
        raise AdapterNotRegisteredError.new("No persistence adapter named #{name} has been registered, avaliable adapters are: #{@adapters.keys.join(', ')}")
      }
    end

    # Dispatches save calls to the adapter from Core
    #
    # @param ticket [Ticket] accepts any of the Ticket subclasses
    # @return [Ticket] returns the ticket with the ID assigned by the adapter
    # @return [False] iff the adapter failed to save the ticket
    #
    # Handles dispatching save calls to the adapter by determing what type of
    # ticket we're trying to save then sending the appropriate message to the
    # adapter with the ticket's attributes hash as the argument.
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
      # @!method load_ticket_granting_ticket(id_or_ticket_string)
      # @!method load_login_ticket(id_or_ticket_string)
      # @!method load_service_ticket(id_or_ticket_string)
      #
      # @param id_or_ticket_string [Id, String] Accepts either the adapter's assigned id or the ticket's
      #   ticket attribute.
      # @return Ticket when the adapter sucessfully loads a record
      # @return NilTicket when Adapter::TicketNotFoundError is thrown by the adapter
      #
      # Loads the requested ticket.
      #
      # The actual finding of ticket the ticket is handled by the adapter
      # which responds to the same method and returns a Hash or other class
      # that provides a key/value pair when #each is called
      %w{login_ticket ticket_granting_ticket service_ticket}.each do |ticket|
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

    # Retreive all ServiceTickets related to the specified TicketGrantingTicket
    #
    # @param ticket_granting_ticket_id (ID) the id assigned to the TGT by the adapter
    # @return [Array<ServiceTicket>]
    # Delegates attribute retrevial to the adapter then instantiates the ticket
    # objects from there.
    def self.service_tickets_for(ticket_granting_ticket_id)
      adapter.service_tickets_for(ticket_granting_ticket_id).map { |st_attrs|
        RubyCAS::Server::Core::Tickets::ServiceTicket.new(st_attrs)
      }
    end
  end
end
