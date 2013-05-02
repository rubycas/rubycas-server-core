module RubyCAS::Server::Core::Persistence
  class InMemory < Adapter

    register_as('in_memory')

    def self.setup(config_file)
      # InMemory adapter do not require any settings
      new
    end

    def initialize
      @tickets = Hash.new { |hash, key|
        # set our default value to be a hash but use the block style definition
        # so we get a different hash each time.
        hash[key] = {}
      }
    end

    %w{login_ticket ticket_granting_ticket}.each do |ticket_type|
      define_method "#{ticket_type}s" do
        @tickets[ticket_type].values
      end

      define_method "save_#{ticket_type}" do |ticket_attributes|
        attrs = ticket_attributes.dup
        attrs[:id] ||= attrs.fetch(:ticket)
        @tickets[ticket_type][attrs[:id]] = attrs
        attrs[:id]
      end
    end
  end
end
