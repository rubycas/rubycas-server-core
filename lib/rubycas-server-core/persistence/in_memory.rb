module RubyCAS::Server::Core::Persistence
  class InMemory < Adapter

    register_as('in_memory')

    def self.setup(config_file)
      # InMemory adapter do not require any settings
      new
    end
  end
end
