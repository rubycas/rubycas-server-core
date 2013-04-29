require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe Ticket do
    describe '#initialize' do
      let(:prefix) { 'ABC' }

      before do
        Ticket.instance_variable_set(:@ticket_prefix, prefix)
      end

      after do
        Ticket.instance_variable_set(:@ticket_prefix, nil)
      end

      it 'must set the ticket string if none is present in the attributes hash' do
        instance = Ticket.new
        instance.ticket.should match /^#{prefix}-\w+/
      end

      it 'must set the ticket string w/ the supplied one from attrs hash' do
        instance = Ticket.new(ticket: 'TGT-QWERTY')
        instance.ticket.should == 'TGT-QWERTY'
      end

      it 'must raise an error when an invalid attribute is attempting to be set' do
        expect{ Ticket.new(garbage: 1234) }.to raise_error Ticket::UnknownAttributeError
      end

      it 'must raise an error when ticket prefix is not set' do
        Ticket.instance_variable_set(:@ticket_prefix, nil)
        expect{ Ticket.new }.to raise_error Ticket::TicketPrefixNotSet
      end
    end

    describe '#save' do
      let(:ticket) {
        klass = Class.new(Ticket) {
          @ticket_prefix = 'ANON'
        }
        klass.new
      }

      it 'must delegate this behaviour to the Persistence module' do
        RubyCAS::Server::Core::Persistence.should_receive(:save_ticket).with(ticket)
        ticket.save
      end
    end

    describe '#valid?' do
      let(:policy) { double }
      let(:ticket) {
        klass = Class.new(Ticket) {
          @ticket_prefix = 'ANON'
        }
        klass.new
      }

      it 'must delegate the validation to the assigned expiration policy' do
        ticket.class.expiration_policy = policy
        policy.should_receive(:ticket_valid?).with(ticket)
        ticket.valid?
      end

      it 'must raise an error when no expiration policy is set' do
        expect{ ticket.valid? }.to raise_error Ticket::ExpirationPolicyNotSet
      end
    end
  end
end
