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

      it 'must set created_at if not present in attributes hash' do
        ticket = Ticket.new
        ticket.created_at.should_not be_nil
      end

      it 'must use created_at if present in attributes hash' do
        time = Time.local(2013, 1, 2, 13, 26)
        ticket = Ticket.new(created_at: time)
        ticket.created_at.should == time
      end

      it 'must set times_used if not present in the attributes hash' do
        ticket = Ticket.new
        ticket.times_used.should == 0
      end

      it 'must use times_used if present in the attributes hash' do
        ticket = Ticket.new(times_used: 3)
        ticket.times_used.should == 3
      end
    end

    describe '#==(other)' do
      let(:ticket_klass) {
        klass = Class.new(Ticket) {
          @ticket_prefix = 'ABC'
        }
      }
      let(:ticket) {
        ticket_klass.new
      }

      describe 'when there is a class missmatch' do
        let(:other_ticket) {
          klass = Class.new(Ticket) {
            @ticket_prefix = 'ABC'
          }
          klass.new
        }
        it 'must return false' do
          ticket.should_not == other_ticket
        end
      end

      describe 'when the classes match' do
        describe 'when the tickets same but have different attributes' do
          let(:duplicate_ticket) {
            duplicate = ticket.dup
            duplicate.times_used = 1
            duplicate
          }

          it 'must return true' do
            ticket.should == duplicate_ticket
          end
        end

        describe 'when the tickets are not the same' do
          let(:other_ticket) { ticket_klass.new }

          it 'must return false' do
            ticket.should_not == other_ticket
          end
        end
      end
    end

    describe '#attributes' do
      let(:time) { Time.local(2013, 1, 25, 13, 25) }
      let(:ticket) {
        klass = Class.new(Ticket) {
          @ticket_prefix = 'ANON'
        }
        klass.new({
          last_used_at: time
        })
      }
      let(:attributes) { ticket.attributes }

      it 'must return a hash with all of the settable values for the class' do
        attributes.keys.sort.should == ['created_at', 'id', 'last_used_at', 'ticket', 'times_used']
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
