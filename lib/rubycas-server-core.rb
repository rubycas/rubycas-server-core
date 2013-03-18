require "logger"
require "r18n-core"
require "rubycas-server-core/core_ext"
require "rubycas-server-core/version"
require "rubycas-server-core/authenticator"
require "rubycas-server-core/settings"
require "rubycas-server-core/database"
$LOG = Logger.new(STDOUT)

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
        R18n.default_places = '../locales'
        R18n.set(Settings.default_locale)
        Database.setup(Settings.database)
      end

      autoload :CredentialRequester, 'rubycas-server-core/credential_requester'
      autoload :Tickets, 'rubycas-server-core/tickets'
      autoload :Util, 'rubycas-server-core/util'
    end
  end
end
