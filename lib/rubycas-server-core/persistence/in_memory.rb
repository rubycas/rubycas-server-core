module RubyCAS
  module Server
    module Core
      module Database
        extend self
        def setup(config_file)
          # InMemory adapter do not require any settings
          return true
        end
      end
    end
  end
end
