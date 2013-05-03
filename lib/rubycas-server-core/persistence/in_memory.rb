require 'set'
require_relative 'adapter'

module RubyCAS::Server::Core::Persistence
  # This is a reference implementation of a persistence adapter for the storage
  # of tickets. It is/will be used for integration testing of everything within
  # core and to make sure the persistence port to the outside world is sane.
  # Please do use this as a reference for what methods need to be present but
  # please don't copy its structure. It is poorly factored and doesn't separate
  # the responsibilities of actual storage and providing the API the 
  # Persistence module expects to be present.
  #
  # @author Tyler Picket <t.pickett66@gmail.com>
  # @since 0.0.1.alpha
  class InMemory < Adapter

    register_as('in_memory')

    # Configure a new instance of the persistence adapter
    #
    # @params config [Hash] you can pass anything in here really because it's
    #   only accepted to keep the API correct
    # @return [InMemory] a newly instantiated InMemory storage adapter
    def self.setup(config_file)
      # InMemory adapter do not require any settings
      new
    end

    class << self
      # I don't like using the class << self style of definitions
      # but YARD won't stop displaying these truly private methods
      # without doing things this way :-(
      private

      def simple_tickets
        %w{login_ticket ticket_granting_ticket}
      end

      def complex_tickets
        %w{service_ticket}
      end

      def all_tickets
        simple_tickets + complex_tickets
      end
    end

    def initialize
      @tickets = Hash.new { |hash, key|
        # set our default value to be a hash but use the block style definition
        # so we get a different hash each time.
        hash[key] = {}
      }
      @relations = Hash.new { |hash, key|
        hash[key] = Hash.new { |subhash, subkey|
          subhash[subkey] = Set.new
        }
      }
    end

    # @!method login_tickets
    # @!method ticket_granting_tickets
    # @!method service_tickets
    #
    # Returns an array all currently stored tickets of the requested type
    #
    # @return [Array<Ticket>] 
    all_tickets.each do |ticket_type|
      define_method "#{ticket_type}s" do
        @tickets[ticket_type].values
      end
    end

    # @!method load_login_ticket(id_or_ticket_string)
    # @!method load_ticket_granting_ticket(id_or_ticket_string)
    # @!method load_service_ticket(id_or_ticket_string)
    #
    #
    # Looks up the requested ticket by either adapter assigned id -or- CAS
    # assigned ticket string, raises an error if no ticket matching that
    # description could be found.
    # 
    # @param id_or_ticket_string [Id, String] Adapter assigned id or the ticket string
    # @return [Ticket]
    # @raise [TicketNotFoundError]
    all_tickets.each do |ticket_type|
      define_method "load_#{ticket_type}" do |id_or_ticket_string|
        @tickets[ticket_type].fetch(id_or_ticket_string) {
          raise TicketNotFoundError.new("Could not find a #{ticket_type.classify} with the ticket: #{id_or_ticket_string}")
        }.dup
      end
    end

    # @!method save_login_ticket(ticket_attributes)
    # @!method save_ticket_granting_ticket(ticket_attributes)
    #
    # Stores the requested ticket attributes and assigns it an ID if one
    # isn't already present.
    #
    # @param ticket_attributes [Hash]
    # @return [ID] the assigned ID
    simple_tickets.each do |ticket_type|
      define_method "save_#{ticket_type}" do |ticket_attributes|
        attrs = ticket_attributes.dup
        attrs[:id] ||= attrs.fetch(:ticket)
        @tickets[ticket_type][attrs[:id]] = attrs
        attrs[:id]
      end
    end

    # Saves a service ticket and adds it's id to the associated records for the
    # specified ticket_granting_ticket.
    # 
    # @param ticket_attributes [Hash]
    # @return [ID] the assigned ID
    def save_service_ticket(ticket_attributes)
      attrs = ticket_attributes.dup
      attrs[:id] ||= attrs.fetch(:ticket)
      @tickets['service_ticket'][attrs[:id]] = attrs

      tgt_id = attrs[:ticket_granting_ticket_id]
      if tgt_id
        @relations['tgt=>st'][tgt_id] << attrs[:id]
      end

      attrs[:id]
    end

    # Looks up all service tickets for the given TicketGrantingTicket and
    # returns their attributes.
    #
    # @param ticket_granting_ticket_id
    # @return [Array<Hash>]
    def service_tickets_for(ticket_granting_ticket_id)
      @relations['tgt=>st'][ticket_granting_ticket_id].map { |st_id|
        @tickets['service_ticket'][st_id]
      }.compact
    end
  end
end
