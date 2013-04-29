module RubyCAS
  module Server
    module Core
      module Persistence
        def self.load_tgt(tgt_string)
          raise NotImplementedError.new('This should be overridden by your adapter of choice')
        end
      end
    end
  end
end
