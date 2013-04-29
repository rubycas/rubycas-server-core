require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe ServiceTicket do
    describe '#initialize' do
      it 'must prefix the ticket string with ST' do
        st = ServiceTicket.new
        st.ticket.should match /^ST-\w+/
      end
    end
  end
end
