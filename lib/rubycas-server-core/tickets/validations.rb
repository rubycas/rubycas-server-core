require "rubycas-server-core/error"

module RubyCAS::Server::Core::Tickets
  module Validations
    include R18n::Helpers
    include RubyCAS::Server::Core::Error

    # Validate login ticket
    #
    # Returned [succes, error_message]
    def validate_login_ticket(ticket)
      $LOG.debug "Validating login ticket '#{ticket}'"
      success = false
      error = nil

      if ticket.nil?
        error = t.error.missing_login_ticket
        $LOG.warn error
      elsif lt = LoginTicket.find_by_ticket(ticket)
        if lt.consumed?
          error = t.error.login_ticket_already_used
          $LOG.warn "Login ticket '#{ticket}' already consumed!"
        elsif not lt.expired?(RubyCAS::Server::Core::Settings.maximum_unused_login_ticket_lifetime)
          $LOG.info "Login ticket '#{ticket}' successfully validated"
          lt.consume!
          success = true
        elsif lt.expired?(RubyCAS::Server::Core::Settings.maximum_unused_login_ticket_lifetime)
          error = t.error.login_timeout
          $LOG.warn "Expired login ticket '#{ticket}'"
        end
      else
        error = t.error.invalid_login_ticket
        $LOG.warn "Invalid login ticket '#{ticket}'"
      end

      return [success, error]
    end

    def validate_ticket_granting_ticket(ticket)
      $LOG.debug "Validating ticket granting ticket '#{ticket}'"
      $LOG.debug "No ticket granting ticket given." if ticket.nil?

      if tgt = TicketGrantingTicket.find_by_ticket(ticket)
        if tgt.remember_me
          max_lifetime = RubyCAS::Server::Core::Settings.maximum_session_lifetime
        else
          max_lifetime = RubyCAS::Server::Core::Settings.maximum_remember_me_lifetime
        end

        if tgt.expired?(max_lifetime)
          tgt.destroy
          error = "Your session has expired. Please log in again."
          $LOG.info "Ticket granting ticket '#{ticket}' for user '#{tgt.username}' expired."
        else
          $LOG.info "Ticket granting ticket '#{ticket}' for user '#{tgt.username}' successfully validated."
        end
      else
        error = "Invalid ticket granting ticket '#{ticket}' (no matching ticket found in the database)."
        $LOG.warn(error)
      end

      [tgt, error]
    end

    def validate_service_ticket(service, ticket, allow_proxy_tickets = false)
      $LOG.debug "Validating service/proxy ticket '#{ticket}' for service '#{service}'"

      if service.nil? or ticket.nil?
        error = Error.new(:INVALID_REQUEST, "Ticket or service parameter was missing in the request.")
        $LOG.warn "#{error.code} - #{error.message}"
      elsif st = ServiceTicket.find_by_ticket(ticket)
        if st.consumed?
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' has already been used up.")
          $LOG.warn "#{error.code} - #{error.message}"
        elsif st.kind_of?(ProxyTicket) && !allow_proxy_tickets
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' is a proxy ticket, but only service tickets are allowed here.")
          $LOG.warn "#{error.code} - #{error.message}"
        elsif st.expired?(RubyCAS::Server::Core::Settings.maximum_unused_service_ticket_lifetime)
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' has expired.")
          $LOG.warn "Ticket '#{ticket}' has expired."
        elsif st.service != service
          error = Error.new(:INVALID_SERVICE, "The ticket '#{ticket}' belonging to user '#{st.username}' is valid,"+
            " but the requested service '#{service}' does not match the service '#{st.service}' associated with this ticket.")
          $LOG.warn "#{error.code} - #{error.message}"
        else
          $LOG.info("Ticket '#{ticket}' for service '#{service}' for user '#{st.username}' successfully validated.")
        end
      else
        error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' not recognized.")
        $LOG.warn("#{error.code} - #{error.message}")
      end

      if st
        st.consume!
      end


      [st, error]
    end

    def validate_proxy_ticket(service, ticket)
      raise NotImplementedError
    end

    def validate_proxy_granting_ticket(ticket)
      raise NotImplementedError
    end

  end
end
