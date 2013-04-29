require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe TicketGrantingTicket do
    describe '#initialize' do
      it 'must set the ticket string with the correct prefix' do
        tgt = TicketGrantingTicket.new
        tgt.ticket.should match /^TGC-\w+/
      end
    end

    describe '#service_tickets' do
      it 'must be implemented' do
        pending('Fetching of service tickets is not yet implemented')
      end
    end

    describe '#proxy_tickets' do
      it 'must be implemented' do
        pending('Fetching of proxy tickets is not yet implemented')
      end
    end
  end
end
