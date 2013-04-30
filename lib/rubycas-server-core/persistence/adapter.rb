module RubyCAS::Server::Core::Peristence
  # Abstract adapter class for persistence, subclass me to implment the full
  # required behavior.
  class Adapter
    class << self
      attr_reader :adapter_name
    end

    def self.register_as(my_name)
      RubyCAS::Server::Core::Persistence.register_adapter(my_name, self)
      @adapter_name = my_name
    end

    def self.setup(config)
      raise NotImplementedError.new("Setup is not implemented for the abstract case, please override me in your implementation.")
    end
  end
end
