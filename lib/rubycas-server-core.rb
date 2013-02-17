require "rubycas-server-core/version"
require "rubycas-server-core/settings"
require "rubycas-server-core/database"

module RubyCAS
  module Server
    module Core
      extend self

      # Read configuration from given file
      # and setup database.
      # Database object is provided by one of the adapter.
      # Please visit: https://github.com/rubycas/rubycas-server-core/wiki
      # for available adapters.
      def setup(config_file)
        Settings.load!(config_file)
        Database.setup(Settings.database)
      end
    end
  end
end
