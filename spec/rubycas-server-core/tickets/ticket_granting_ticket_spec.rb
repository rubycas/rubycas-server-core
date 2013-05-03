require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe TicketGrantingTicket do
    describe '#initialize' do
      it 'must set the ticket string with the correct prefix' do
        tgt = TicketGrantingTicket.new
        tgt.ticket.should match /^TGC-\w+/
      end
    end

    describe '#proxy_tickets' do
      it 'must be implemented' do
        pending('Fetching of proxy tickets is not yet implemented')
      end
    end

    describe '#service_tickets' do
      let(:tgt_id) { SecureRandom.uuid }

      before do
        subject.id = tgt_id
        RubyCAS::Server::Core::Persistence.should_receive(:service_tickets_for).with(tgt_id).and_return([])
      end

      it 'must delegate fetching the tickets to the persistence module' do
        subject.service_tickets
      end

      it 'must cache the potentially expensive return result' do
        subject.service_tickets # initial call hits the mock from the before block
        subject.service_tickets # second call hits cache
      end
    end
  end
end
