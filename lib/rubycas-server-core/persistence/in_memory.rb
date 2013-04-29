module RubyCAS::Server::Core::Persistence
  class InMemory < Adapter

    register_as('in_memory')

    def self.setup(config_file)
      # InMemory adapter do not require any settings
      new
    end

    def initialize
      @tickets = {}
    end

    def save_ticket(ticket)
      ticket.id ||= ticket.ticket
      @tickets[ticket.class] ||= {}
      @tickets[ticket.class][ticket.id] = ticket.attributes
    end
  end
end
