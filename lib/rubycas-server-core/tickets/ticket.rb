require_relative '../util'

module RubyCAS::Server::Core::Tickets

  # Abstract class for shared ticket functionality
  #
  # @author Tyler Pickett
  # @abstract
  # @since 0.1.0.alpha
  # @attr [Time] created_at When the ticket was first initialized
  # @attr id The id assigned to this ticket by the persistence layer
  # @attr [Time] last_used_at When the ticket was last used
  # @attr [Fixnum] times_used The number of times the ticket has been used
  class Ticket

    # Raised when an attribute is passed to the constructor that doesn't
    # have a setter.
    class UnknownAttributeError < StandardError; end

    # Raised on intialization when the inherited class doesn't specify
    # how to prefix ticket strings
    class TicketPrefixNotSet < StandardError; end

    # Raised when trying to validate a ticket but an expiration policy
    # hasn't been set
    class ExpirationPolicyNotSet < StandardError; end

    class << self
      # Ivar for expiration policy class to delegate validation to.
      attr_accessor :expiration_policy

      # Ivar for use in generating ticket strings, gets prepended to the
      # randomly generated portion. Best set in the subclass' definition
      attr_reader :ticket_prefix
    end

    attr_accessor :created_at, :id, :last_used_at, :ticket, :times_used

    def self.fields
      @fields ||= instance_methods.sort.select{|setter| setter.to_s =~ /[\w_]=+$/}.map{|setter| setter.to_s.gsub(/=$/,'')}
    end

    def initialize(attributes = {})
      set_attributes(attributes)
      set_ticket_string
      @created_at ||= Time.now
      @times_used ||= 0
    end

    def ==(other)
      return false if self.class != other.class
      self.ticket == other.ticket
    end

    def attributes
      fields.reduce(HashWithIndifferentAccess.new) { |attrs, field|
        attrs[field] = send(field)
        attrs
      }
    end

    # retreives the expiration policy set by configs for the subclass
    def expiration_policy
      self.class.expiration_policy
    end

    def fields
      self.class.fields
    end

    # Adds ease to storing tickets. Delegates actual work to the persistence
    # module.
    def save
      RubyCAS::Server::Core::Persistence.save_ticket(self)
    end

    # Enables tickets to be checked for validity, delegates actual work to the
    # expiration policy set for the class.
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
