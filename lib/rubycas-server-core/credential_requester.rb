module RubyCAS::Server::Core
  class CredentialRequester
    attr_reader :listener

    def initialize(listener)
      @listener = listener
    end

    def process!(params = {}, cookies = {})
      ticket = Tickets.generate_login_ticket
      listener.user_not_logged_in(ticket.ticket)
    end
  end
end
