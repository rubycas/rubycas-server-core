module RubyCAS
  module Server
    module Core
      module Tickets
        class LoginTicket < Storage
          attr_accessor :id, :ticket, :consumed, :client_hostname,
                      :created_at, :updated_at


          def initialize(lt = {})
            @id = SecureRandom.uuid
            @ticket = lt[:ticket]
            @consumed = lt[:consumed]
            @client_hostname = lt[:client_hostname]
            @created_at = DateTime.now
            @updated_at = DateTime.now
            super()
          end

          def self.find_by_ticket(ticket)
            @storage.each do |id,lt|
              return lt if lt.ticket == ticket
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
