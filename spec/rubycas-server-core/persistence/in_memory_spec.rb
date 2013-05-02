require 'spec_helper'

module RubyCAS::Server::Core::Persistence
  describe InMemory do
    let(:config) { {} }
    let(:adapter) { InMemory.new }

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

    describe '#load_login_ticket(id_or_ticket_string)' do
      let(:ticket_string) { 'LT-123456' }
      let(:ticket_attrs) { {ticket: ticket_string, client_hostname: 'myhost.local'} }

      context 'when the ticket has been previously stored' do
        before do
          @id = adapter.save_login_ticket(ticket_attrs)
        end

        it "must return a hash containing the ticket's atrributes when passed the ticket string" do
          adapter.load_login_ticket(ticket_string).should == ticket_attrs.merge(id: @id)
        end

        it "must return a hash containing the ticket's attributes when passed the id" do
          adapter.load_login_ticket(@id).should == ticket_attrs.merge(id: @id)
        end
      end

      context 'when the ticket has never been stored' do
        it 'must raise Adapter::TicketNotFoundError' do
          expect{ adapter.load_login_ticket(ticket_string) }.to raise_error Adapter::TicketNotFoundError
        end
      end
    end

    describe '#load_ticket_granting_ticket(ticket_string)' do
      let(:ticket_string) { 'TGT-123456' }
      let(:ticket_attrs) { {id: ticket_string, ticket: ticket_string, client_hostname: 'myhost.local'} }

      context 'when the ticket has been previously stored' do
        before do
          @id = adapter.save_ticket_granting_ticket(ticket_attrs)
        end

        it "must return the a hash containing the ticket's atrributes when passed the ticket string" do
          adapter.load_ticket_granting_ticket(ticket_string).should == ticket_attrs.merge(id: @id)
        end

        it "must return a hash containing the ticket's attributes when passed the id" do
          adapter.load_ticket_granting_ticket(@id).should == ticket_attrs.merge(id: @id)
        end
      end

      context 'when the ticket has never been stored' do
        it 'must raise Adapter::TicketNotFoundError' do
          expect{ adapter.load_ticket_granting_ticket(ticket_string) }.to raise_error Adapter::TicketNotFoundError
        end
      end
    end
  end
end
