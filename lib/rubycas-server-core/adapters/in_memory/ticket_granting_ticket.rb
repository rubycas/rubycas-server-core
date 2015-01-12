module RubyCAS
  module Server
    module Core
      module Tickets
        class TicketGrantingTicket < Storage
          attr_accessor :id, :ticket, :client_hostname, :username,
                        :extra_attributes, :service_tickets, :proxy_tickets,
                        :remember_me, :created_at, :updated_at

          def initialize(tgt = {})
            @id = SecureRandom.uuid
            @ticket = tgt[:ticket]
            @client_hostname = tgt[:client_hostname]
            @username = tgt[:username]
            @extra_attributes = tgt[:extra_attributes]
            @service_tickets = tgt[:service_tickets]
            @proxy_tickets = tgt[:proxy_tickets]
            @remember_me = tgt[:remember_me]
            @created_at = DateTime.now
            @updated_at = DateTime.now
            super()
          end

          def self.find_by_ticket(ticket)
            @storage.each do |id, tgt|
              return tgt if tgt.ticket == ticket
            end
            return nil
          end

          def expired?(max_lifetime)
            lifetime = Time.now.to_i - created_at.to_time.to_i
            lifetime > max_lifetime
          end

          def service_tickets
            ServiceTicket
          end
        end
      end
    end
  end
end
