module RubyCAS::Server::Core::Tickets
  class NilTicket < Ticket
    @ticket_prefix = 'NIL'
    @fields = []

    %w{present? save valid?}.each do |method|
      define_method method do
        false
      end
    end

    def attributes
      HashWithIndifferentAccess.new
    end
  end
end
