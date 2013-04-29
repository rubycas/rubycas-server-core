require_relative 'ticket'

module RubyCAS::Server::Core::Tickets
  class ServiceTicket < Ticket
    attr_accessor :service, :ticket_granting_ticket_id

    @ticket_prefix = 'ST'

  end
end
