require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe ServiceTicket do
    describe '#initialize' do
      it 'must prefix the ticket string with ST' do
        st = ServiceTicket.new
        st.ticket.should match /^ST-/
      end
    end

    describe '#ticket_granting_ticket' do
      context 'when ticket granting ticket id is nil' do
        it 'must return a NilTicket' do
          ticket = subject.ticket_granting_ticket
          ticket.should be_a NilTicket
        end
      end

      context 'when ticket granting ticket id is set' do
        let(:tgt_id) { SecureRandom.uuid }
        it 'should delegate the work to the persistence module' do
          subject.ticket_granting_ticket_id = tgt_id
          RubyCAS::Server::Core::Persistence.should_receive(:load_ticket_granting_ticket).with(tgt_id)
          subject.ticket_granting_ticket
        end
      end
    end
  end
end
