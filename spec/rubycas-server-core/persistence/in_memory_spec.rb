require 'spec_helper'

module RubyCAS::Server::Core::Persistence
  describe InMemory do
    let(:config) { {} }
    let(:adapter) { RubyCAS::Server::Core::Persistence.adapter }
    let(:ticket) { RubyCAS::Server::Core::Tickets::LoginTicket.new }

    before(:all) do
      RubyCAS::Server::Core::Persistence.setup({adapter: 'in_memory'})
    end

    it 'must register it self with the persistence module' do
      RubyCAS::Server::Core::Persistence.adapter_named(described_class.adapter_name).should eq described_class
    end

    describe '#save_ticket' do
      describe 'for a new ticket' do
        before do
          RubyCAS::Server::Core::Persistence.save_ticket(ticket)
        end

        it 'must set the assigned id on the ticket passed in' do
          ticket.id.should_not be_nil
        end
      end
    end
    end
  end
end
