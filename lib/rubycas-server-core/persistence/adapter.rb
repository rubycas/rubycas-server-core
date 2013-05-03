module RubyCAS::Server::Core::Persistence
  # Abstract adapter class for persistence, subclass me to implment the full
  # required behavior.
  #
  # @see InMemory InMemory for an actual adapter implemenation.
  # == Example Subclass
  #   class MySpecialAdapter < Adapter
  #     register_as 'my_special_adapter'
  #
  #     ... skipped implementation ...
  #   end
  #
  class Adapter

    # Raised by an adapter implementation when an ticket requested by string or
    # id can't be found
    class TicketNotFoundError < StandardError; end

    class << self
      # The name assigned to this adapter, this gets set by the adapter as
      # part of the registration process. This is public so the test harnnes
      # can get at it but the registration method is private because we really
      # don't need others to be messing with that.
      attr_reader :adapter_name
    end

    private

    def self.register_as(my_name)
      RubyCAS::Server::Core::Persistence.register_adapter(my_name, self)
      @adapter_name = my_name
    end
  end
end
