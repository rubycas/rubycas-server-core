require 'yaml'

module RubyCAS
  module Server
    module Core
      module Settings
        extend self

        @_settings = HashWithIndifferentAccess.new
        attr_reader :_settings

        def load!(file_name)
          config = YAML::load_file(file_name).with_indifferent_access
          @_settings.merge!(config)
        end

        def method_missing(name, *args, &block)
          @_settings[name.to_sym] || fail(NoMethodError, "unknown configuration: #{name}", caller)
        end

      end
    end
  end
end
