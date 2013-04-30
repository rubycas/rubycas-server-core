require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe LoginTicket do
    describe '#initialize(atributes)' do
      it 'should set the ticket string without input' do
        lt = LoginTicket.new
        lt.ticket.should match /^LT-\w+/
      end
    end
  end
end
