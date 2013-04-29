require 'rubycas-server-core/util'
%w{login_ticket ticket_granting_ticket service_ticket}.each do |ticket_type|
  require_relative "tickets/#{ticket_type}"
end

module RubyCAS
  module Server
    module Core
      module Tickets

        # One time login ticket for given client
        def self.generate_login_ticket(client)
          lt = LoginTicket.new
          lt.client_hostname = client
          if lt.save
            $LOG.debug("Login ticket '#{lt.ticket} has been created for '#{lt.client_hostname}'")
            return lt
          else
            return nil
          end
        end

        # Creates a TicketGrantingTicket for the given username. This is done when the user logs in
        # for the first time to establish their SSO session (after their credentials have been validated).
        #
        # The optional 'extra_attributes' parameter takes a hash of additional attributes
        # that will be sent along with the username in the CAS response to subsequent
        # validation requests from clients.
        def self.generate_ticket_granting_ticket(username, client, extra_attributes = {})
          tgt = TicketGrantingTicket.new({
            username: username,
            extra_attributes: extra_attributes,
            client_hostname: client
          })
          if tgt.save
            $LOG.debug("Generated ticket granting ticket '#{tgt.ticket}' for user" +
              " '#{tgt.username}' at '#{tgt.client_hostname}'" +
              (extra_attributes.empty? ? "" : " with extra attributes #{extra_attributes.inspect}"))
            return tgt
          else
            return nil
          end
        end

        class << self
          %w{login_ticket service_ticket ticket_granting_ticket}.each do |ticket_type|
            define_method "#{ticket_type}_valid?" do |ticket_string|
              $LOG.debug "Validating #{ticket_type.gsub(/_/, ' ')} '#{ticket_string}'"

              if ticket_string.blank?
                $LOG.debug "No ticket."
                raise ArgumentError.new("No ticket string supplied for validation")
              else
                ticket = Persistence.public_send("load_#{ticket_type}", ticket_string)
                ticket.valid?
              end
            end
          end
        end

        def self.generate_service_ticket(service, tgt)
          st = ServiceTicket.new({
            service: service,
            ticket_granting_ticket_id: tgt.id
          })
          if st.save
            $LOG.debug("Generated service ticket '#{st.ticket}' for service '#{st.service}'" +
              " for user '#{tgt.username}' at '#{tgt.client_hostname}'")
            return st
          else
            return nil
          end
        end

        def self.generate_proxy_ticket(target_service, pgt, client)
          raise NotImplementedError
        end

        def self.generate_proxy_granting_ticket(pgt_url, st, client)
          raise NotImplementedError
        end
      end
    end
  end
end
