module RubyCAS
  module Server
    module Core
      module Tickets
        class ProxyTicket < Storage

          attr_accessor :id, :ticket, :service, :consumed, :client_hostname,
                        :username, :created_at, :updated_at, :proxy_granting_ticket,
                        :ticket_granting_ticket

          def initialize(pt = {})
            @id = SecureRandom.uuid
            @ticket = pt[:ticket]
            @service = pt[:service]
            @consumed = pt[:consumed]
            @client_hostname = pt[:client_hostname]
            @username = pt[:username]
            @created_at = DateTime.now
            @updated_at = DateTime.now
            @proxy_granting_ticket = pt[:proxy_granting_ticket]
            @ticket_granting_ticket = pt[:ticket_granting_ticket]
            super()
          end


          def self.find_by_ticket(ticket)
            @storage.each do |id,pt|
              return pt if pt.ticket == ticket
            end
            return nil
          end

          def consumed?
            consumed
          end

          def consume!
            consumed = true
            self.save
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
