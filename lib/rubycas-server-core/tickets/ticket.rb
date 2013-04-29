require_relative '../util'

module RubyCAS::Server::Core::Tickets
  class Ticket
    class UnknownAttributeError < StandardError; end
    class TicketPrefixNotSet < StandardError; end
    class ExpirationPolicyNotSet < StandardError; end

    class << self
      # doing this as a class instance variable because class variables are evil
      attr_accessor :expiration_policy
      attr_reader :ticket_prefix
    end

    # common attributes across all tickets
    attr_accessor :created_at, :id, :last_used_at, :ticket, :times_used

    def initialize(attributes = {})
      set_attributes(attributes)
      set_ticket_string
    end

    def expiration_policy
      self.class.expiration_policy
    end

    def save
      RubyCAS::Server::Core::Persistence.save_ticket(self)
    end

    def valid?
      if expiration_policy.present?
        expiration_policy.ticket_valid?(self)
      else
        $LOG.error("No expiration policy set for #{self.class}, can't validate!")
        raise ExpirationPolicyNotSet.new("No expiration policy set for #{self.class}")
      end
    end

    protected

    def ticket_prefix
      self.class.ticket_prefix
    end

    def set_attributes(attributes)
      attributes.each do |attr, value|
        setter = "#{attr}="
        if respond_to?(setter)
          send(setter, value)
        else
          raise UnknownAttributeError.new("Unknown attribute #{attr} for #{self.class}")
        end
      end
    end

    def set_ticket_string
      return if self.ticket.present?
      if ticket_prefix.present?
        self.ticket = "#{ticket_prefix}-#{RubyCAS::Server::Core::Util.random_string}"
      else
        raise TicketPrefixNotSet.new("No ticket prefix set for class #{self.class}")
      end
    end
  end
end
