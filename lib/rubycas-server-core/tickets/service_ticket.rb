require_relative 'ticket'

module RubyCAS::Server::Core::Tickets
  class ServiceTicket < Ticket
    attr_accessor :service, :ticket_granting_ticket_id

    @ticket_prefix = 'ST'

    def ticket_granting_ticket
      return NilTicket.new if ticket_granting_ticket_id.nil?
      RubyCAS::Server::Core::Persistence.load_ticket_granting_ticket(ticket_granting_ticket_id)
    end
  end
end
