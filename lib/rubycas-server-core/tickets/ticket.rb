module RubyCAS::Server::Core::Tickets
  class Ticket
    class << self
      # doing this as a class instance variable because class variables are evil
      attr_accessor :expiration_policy
    end

    # common attributes across all tickets
    attr_accessor :created_at, :id, :last_used_at, :ticket, :times_used

    def save
      RubyCAS::Server::Core::Persistence.save_ticket(self)
    end
  end
end
