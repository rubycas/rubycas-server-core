require 'spec_helper'

module RubyCAS::Server::Core::Persistence
  describe InMemory do
    let(:config) { {} }
    let(:adapter) { RubyCAS::Server::Core::Persistence.adapter }

    before(:all) do
      RubyCAS::Server::Core::Persistence.setup({adapter: 'in_memory'})
    end

    it 'must register it self with the persistence module' do
      RubyCAS::Server::Core::Persistence.adapter_named(described_class.adapter_name).should eq described_class
    end

    describe '#save_login_ticket(ticket_attributes)' do
      describe 'for a new ticket' do
        let(:attrs) { {ticket: 'LT-12345'} }

        before do
          @return_value = adapter.save_login_ticket(attrs)
        end

        it 'must store the ticket in an accessable fashion with its id' do
          adapter.login_tickets.should include(attrs.merge({id: @return_value}))
        end

        it 'must return the assigned id' do
          @return_value.should_not be_nil
        end
      end

      describe 'for a previously saved ticket' do
        let(:id) { 'super_awesome_id' }
        let(:attrs) { {ticket: 'LT-12345', id: id} }

        before do
          @return_value = adapter.save_login_ticket(attrs)
        end

        it 'must store the ticket in an accessable fashion with its id' do
          adapter.login_tickets.should include(attrs)
        end

        it 'must return the assigned id' do
          @return_value.should == id
        end
      end
    end

    describe '#save_ticket_granting_ticket(ticket_attributes)' do
      describe 'for a new ticket' do
        let(:attrs) { {ticket: 'TGT-12345'} }

        before do
          @return_value = adapter.save_ticket_granting_ticket(attrs)
        end

        it 'must store the ticket in an accessable fashion with its id' do
          adapter.ticket_granting_tickets.should include(attrs.merge({id: @return_value}))
        end

        it 'must return the assigned id' do
          @return_value.should_not be_nil
        end
      end

      describe 'for a previously saved ticket' do
        let(:id) { 'super_awesome_id' }
        let(:attrs) { {ticket: 'TGT-12345', id: id} }

        before do
          @return_value = adapter.save_ticket_granting_ticket(attrs)
        end

        it 'must store the ticket in an accessable fashion with its id' do
          adapter.ticket_granting_tickets.should include(attrs)
        end

        it 'must return the assigned id' do
          @return_value.should == id
        end
      end
    end
  end
end
