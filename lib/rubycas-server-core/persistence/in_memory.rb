module RubyCAS::Server::Core::Persistence
  module InMemory
    RubyCAS::Server::Core::Persistence.register_adapter(:in_memory, self)

    def self.setup(config_file)
      # InMemory adapter do not require any settings
      return true
    end
  end
end
