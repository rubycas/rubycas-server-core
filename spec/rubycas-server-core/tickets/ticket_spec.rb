require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe Ticket do
    describe '#save' do
      let(:ticket) { double(Ticket) }

      it 'must delegate this behaviour to the Persistance module' do
        Persistence.should_receive(:save_ticket).with(ticket)
        ticket.save
      end
    end
  end
end
