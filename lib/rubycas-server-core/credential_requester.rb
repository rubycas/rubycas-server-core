module RubyCAS::Server::Core
  class CredentialRequester
    attr_reader :listener

    def initialize(listener)
      @listener = listener
    end

    def process!(params = {}, cookies = {})
      tgt = cookies['tgt']
      service = Util.clean_service_url(params['service'])
      if tgt && Tickets.ticket_granting_ticket_valid?(tgt)
        st = Tickets.generate_service_ticket(service, tgt)
        target = Util.build_ticketed_url(service, st.ticket)
        listener.user_logged_in(target)
      else
        ticket = Tickets.generate_login_ticket
        listener.user_not_logged_in(ticket.ticket)
      end
    end
  end
end
