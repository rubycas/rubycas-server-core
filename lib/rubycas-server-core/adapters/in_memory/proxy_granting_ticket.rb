module RubyCAS
  module Server
    module Core
      module Tickets
        class ProxyGrantingTicket < Storage

          attr_accessor :id, :ticket, :client_hostname, :iou,
                        :created_at, :updated_at, :service_ticket,
                        :proxy_tickets

          def initialize(pgt = {})
            @id = SecureRandom.uuid
            @ticket = pgt[:ticket]
            @client_hostname = pgt[:client_hostname]
            @created_at = DateTime.now
            @updated_at = DateTime.now
            @service_ticket = pgt[:service_ticket]
            @proxy_tickets = pgt[:proxy_tickets]
            super()
          end


          def self.find_by_ticket(ticket)
            @storage.each do |id,pgt|
              return pgt if pgt.ticket == ticket
            end
            return nil
          end

          def expired?(max_lifetime = 100)
            lifetime = Time.now.to_i - created_at.to_time.to_i
            lifetime > max_lifetime
          end
        end
      end
    end
  end
end
