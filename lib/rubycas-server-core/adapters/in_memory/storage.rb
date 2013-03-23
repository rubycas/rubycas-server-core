module RubyCAS
  module Server
    module Core
      module CAS
        class Storage
          class << self
            attr_accessor :storage
          end

          def initialize
            self.class.storage = {} unless self.class.storage
          end

          def save
            self.class.storage[@id] = self
            return true
          end

        end
      end
    end
  end
end
