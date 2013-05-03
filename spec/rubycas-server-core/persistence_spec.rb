require 'spec_helper'

module RubyCAS::Server::Core
  describe Persistence do
    let(:name) { :awesome_adapter }
    let(:klass) { double }
    let(:adapter) { double }

    before do
      Persistence.register_adapter(name, klass)
      Persistence.instance_variable_set(:@adapter, adapter)
    end

    describe '.setup(config)' do
      let(:config) { {
        adapter: name.to_s,
        address: '127.0.0.1',
        password: 'super'
      } }

      before do
        klass.should_receive(:setup).with(config)
      end

      it 'must pass the config on to the selected adapter' do
        Persistence.setup(config)
      end
    end

    describe '.adapter_named' do
      it 'must raise an error when an un-registered name is supplied' do
        expect{ Persistence.adapter_named(:garbage) }.to raise_error Persistence::AdapterNotRegisteredError
      end

      it 'must return the class registered to that name' do
        Persistence.adapter_named(name.to_s).should eq klass
      end
    end

    describe '.register_adapter(adapter_name, handler)' do
      it 'must allow us to look up the adapter class by giving the name' do
        Persistence.adapter_named(name).should eq klass
      end
    end

    describe '.save_ticket(ticket)' do
      let(:id) { SecureRandom.uuid }

      describe 'when passed a LoginTicket' do
        let(:ticket) { RubyCAS::Server::Core::Tickets::LoginTicket.new(client_hostname: 'bob') }

        before do
          adapter.should_receive(:save_login_ticket).with(ticket.attributes).and_return(id)
          Persistence.save_ticket(ticket)
        end

        it 'must use the return value from the adapter to set the id of our ticket' do
          ticket.id.should == id
        end
      end

      describe 'when passed a TicketGrantingTicket' do
        let(:ticket) { RubyCAS::Server::Core::Tickets::TicketGrantingTicket.new(client_hostname: 'bob') }

        before do
          adapter.should_receive(:save_ticket_granting_ticket).with(ticket.attributes).and_return(id)
          Persistence.save_ticket(ticket)
        end

        it 'must use the return value from the adapter to set the id of our ticket' do
          ticket.id.should == id
        end
      end

      describe "when the adapter can't save the ticket" do
        let(:ticket) { RubyCAS::Server::Core::Tickets::LoginTicket.new(client_hostname: 'bob') }

        before do
          adapter.should_receive(:save_login_ticket).with(ticket.attributes).and_return(false)
        end

        it 'must return false to indicate failure' do
          Persistence.save_ticket(ticket).should be false
        end
      end
    end

    describe '.load_login_ticket(ticket_string)' do
      let(:client) { 'mycomputer.home' }
      let(:id) { SecureRandom.uuid }
      let(:ticket) { RubyCAS::Server::Core::Tickets::LoginTicket.new({id: id, client_hostname: client}) }

      context 'for an already stored ticket' do
        before do
          adapter.should_receive(:load_login_ticket).with(ticket.ticket).and_return(ticket.attributes)
          @loaded_ticket = Persistence.load_login_ticket(ticket.ticket)
        end

        it 'must return the correct ticket' do
          @loaded_ticket.should == ticket
        end

        it 'must not return the same instance that was submitted for saving' do
          @loaded_ticket.object_id.should_not == ticket.object_id
        end
      end

      context 'for a ticket that is unknown to the adapter' do
        before do
          adapter.should_receive(:load_login_ticket).with(ticket.ticket).and_raise Persistence::Adapter::TicketNotFoundError.new('blah blah blah')
          @loaded_ticket = Persistence.load_login_ticket(ticket.ticket)
        end

        it 'must return a NilTicket' do
          @loaded_ticket.should be_a RubyCAS::Server::Core::Tickets::NilTicket
        end
      end
    end

    describe '.load_ticket_granting_ticket(ticket_string)' do
      let(:client) { 'mycomputer.home' }
      let(:id) { SecureRandom.uuid }
      let(:ticket) { RubyCAS::Server::Core::Tickets::TicketGrantingTicket.new({id: id, client_hostname: client}) }

      context 'for an already stored ticket' do
        before do
          adapter.should_receive(:load_ticket_granting_ticket).with(ticket.ticket).and_return(ticket.attributes)
          @loaded_ticket = Persistence.load_ticket_granting_ticket(ticket.ticket)
        end

        it 'must return the correct ticket' do
          @loaded_ticket.should == ticket
        end

        it 'must not return the same instance that was submitted for saving' do
          @loaded_ticket.object_id.should_not == ticket.object_id
        end
      end

      context 'for a ticket that is unknown to the adapter' do
        before do
          adapter.should_receive(:load_ticket_granting_ticket).with(ticket.ticket).and_raise Persistence::Adapter::TicketNotFoundError.new('blah blah blah')
          @loaded_ticket = Persistence.load_ticket_granting_ticket(ticket.ticket)
        end

        it 'must return a NilTicket' do
          @loaded_ticket.should be_a RubyCAS::Server::Core::Tickets::NilTicket
        end
      end
    end

    describe '.service_tickets_for(ticket_granting_ticket_id)' do
      let(:tgt_id) { SecureRandom.uuid }
      let(:tgt) { RubyCAS::Server::Core::Tickets::TicketGrantingTicket.new({id: tgt_id}) }
      let(:st_id) { SecureRandom.uuid }
      let(:st) { RubyCAS::Server::Core::Tickets::ServiceTicket.new({id: st_id}) }
      let(:service_tickets) { Persistence.service_tickets_for(tgt_id) }

      before do
        adapter.should_receive(:service_tickets_for).with(tgt_id).and_return([st.attributes])
      end

      it 'must return an array of ServiceTickets' do
        service_tickets.should include st
      end
    end
  end
end
