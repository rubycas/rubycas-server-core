module RubyCAS
  module Server
    module Core
      module Database
        extend self
        def setup(config_file)
          raise NotImplementedError, "Database adapter is missing, add it to your Gemfile, please refer to https://github.com/rubycas/rubycas-server-core/wiki for more details"
        end
      end
    end
  end
end
