require 'spec_helper'

module RubyCAS::Server::Core
  describe Persistence do
    let(:name) { :awesome_adapter }
    let(:klass) { double }

    before do
      Persistence.register_adapter(name, klass)
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
      let(:adapter) { double }
      let(:id) { SecureRandom.uuid }

      before do
        Persistence.instance_variable_set(:@adapter, adapter)
      end

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
  end
end
