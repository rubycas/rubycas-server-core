require 'securerandom'

module RubyCAS
  module Server
    module Core
      module String
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # Helper method to generate url safe random string
          def random(length = 29)
            SecureRandom.urlsafe_base64(length)[0..length-1]
          end
        end
      end
    end
  end
end
