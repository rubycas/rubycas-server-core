require 'rubycas-server-core/util'

module RubyCAS
  module Server
    module Core
      module Tickets
        class LT
          extend ::RubyCAS::Server::Core::Tickets::Generations
          extend ::RubyCAS::Server::Core::Tickets::Validations

          def self.create!(client = "localhost")
            lt = generate_login_ticket(client)
            raise 'error that should be handled by rubycas-server-core gem' if !lt
            return lt
          end

          def self.create(client = "localhost")
            generate_login_ticket(client)
          end

          def self.validate(lt)
            validate_login_ticket(lt)
          end

          def self.find_by(options)
            Tickets::LoginTicket.find_by(
              options
            )
          end

          def self.find_by!(options)
            lt = Tickets::LoginTicket.find_by(
              options
            )
            raise 'error that should be handled by rubycas-server-core gem' if !lt
            return lt
          end
        end

        class TGT
          extend ::RubyCAS::Server::Core::Tickets::Generations
          extend ::RubyCAS::Server::Core::Tickets::Validations

          def self.create!(user, client = "localhost", remember_me = false, extra_attributes = {})
            tgt = generate_ticket_granting_ticket(
              user, client, remember_me, extra_attributes
            )
            raise 'error that should be handled by rubycas-server-core gem' if !tgt
            return tgt
          end

          def self.create(user, client = "localhost", remember_me = false, extra_attributes = {})
            generate_ticket_granting_ticket(
              user, client, remember_me, extra_attributes
            )
          end

          def self.validate(tgt)
            validate_ticket_granting_ticket(tgt)
          end


          def self.find_by(options)
            Tickets::TicketGrantingTicket.find_by(
              options
            )
          end

          def self.find_by!(options)
            tgt = Tickets::TicketGrantingTicket.find_by(
              options
            )
            raise 'error that should be handled by rubycas-server-core gem' if !tgt
            return tgt
          end
        end

        class ST
          extend ::RubyCAS::Server::Core::Tickets::Generations
          extend ::RubyCAS::Server::Core::Tickets::Validations

          def self.create!(service, user, tgt, client="localhost")
            st = generate_service_ticket(service, user, tgt, client)
            raise 'error that should be handled by rubycas-server-core gem' if !st
            return st
          end

          def self.create(service, user, tgt, client="localhost")
            generate_service_ticket(service, user, tgt, client)
          end

          def self.validate(service, ticket)
            validate_service_ticket(service, ticket)
          end

          def self.find_by(options)
            Tickets::ServiceTicket.find_by(
              options
            )
          end

          def self.find_by!(options)
            st = Tickets::ServiceTicket.find_by(
              options
            )
            raise 'error that should be handled by rubycas-server-core gem' if !st
            return st
          end
        end

        class Utils
          include ::RubyCAS::Server::Core

          def self.clean_service_url(service_url)
            return "" if service_url.nil?
            service_url.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '')
            service_url.encode!('UTF-8', 'UTF-16')
            Util.clean_service_url(service_url)
          end

          def self.build_ticketed_url(service, ticket)
            Util.build_ticketed_url(service, ticket)
          end
        end
      end
    end
  end
end
