module RubyCAS::Server::Core
  class CredentialRequester
    attr_reader :listener

    def initialize(listener)
      @listener = listener
    end

    def process!(params = {}, cookies = {})
      tgt = cookies['tgt']
      tgt_valid, tgt_message = Tickets.ticket_granting_ticket_valid?(tgt) if tgt.present?

      service = Util.clean_service_url(params['service'])

      if params['gateway'] && service.present? # allow any truthy value for gateway
        if tgt && tgt_valid
          st = Tickets.generate_service_ticket(service, tgt)
          target = Util.build_ticketed_url(service, st.ticket)
        else
          target = service
        end

        listener.user_logged_in(target)
      elsif tgt && tgt_valid && params['gateway'].blank?
        st = Tickets.generate_service_ticket(service, tgt)
        target = Util.build_ticketed_url(service, st.ticket)
        listener.user_logged_in(target)
      else
        ticket = Tickets.generate_login_ticket
        listener.user_not_logged_in(ticket.ticket, tgt_message)
      end
    end
  end
end
