module RubyCAS::Server::Core::Peristence
  module InMemory
    def self.setup(config_file)
      # InMemory adapter do not require any settings
      return true
    end
  end
end
