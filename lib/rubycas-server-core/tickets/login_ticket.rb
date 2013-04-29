require_relative 'ticket'

module RubyCAS::Server::Core::Tickets
  class LoginTicket < Ticket
    attr_accessor :client_hostname

    @ticket_prefix = 'LT'
  end
end
