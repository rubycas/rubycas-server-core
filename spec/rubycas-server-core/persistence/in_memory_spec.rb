require 'spec_helper'

module RubyCAS::Server::Core::Persistence
  describe InMemory do
    it 'must register it self with the persistence module' do
      RubyCAS::Server::Core::Persistence.adapter_named(described_class.adapter_name).should eq described_class
    end
    end
  end
end
