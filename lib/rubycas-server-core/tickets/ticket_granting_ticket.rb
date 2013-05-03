require_relative 'ticket'

module RubyCAS::Server::Core::Tickets
  class TicketGrantingTicket < Ticket
    attr_accessor :client_hostname, :username, :extra_attributes

    @ticket_prefix = 'TGC'

    def proxy_tickets
      raise NotImplementedError.new
    end

    def service_tickets
      @service_tickets ||= RubyCAS::Server::Core::Persistence.service_tickets_for(id)
    end
  end
end
