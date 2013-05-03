require 'set'
require_relative 'adapter'

module RubyCAS::Server::Core::Persistence
  class InMemory < Adapter

    register_as('in_memory')

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

    all_tickets.each do |ticket_type|
      define_method "#{ticket_type}s" do
        @tickets[ticket_type].values
      end

      define_method "load_#{ticket_type}" do |id_or_ticket_string|
        @tickets[ticket_type].fetch(id_or_ticket_string) {
          raise TicketNotFoundError.new("Could not find a #{ticket_type.classify} with the ticket: #{id_or_ticket_string}")
        }.dup
      end
    end

    simple_tickets.each do |ticket_type|
      define_method "save_#{ticket_type}" do |ticket_attributes|
        attrs = ticket_attributes.dup
        attrs[:id] ||= attrs.fetch(:ticket)
        @tickets[ticket_type][attrs[:id]] = attrs
        attrs[:id]
      end
    end

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

    def service_tickets_for(ticket_granting_ticket_id)
      @relations['tgt=>st'][ticket_granting_ticket_id].map { |st_id|
        @tickets['service_ticket'][st_id]
      }.compact
    end
  end
end
