require "spec_helper"

module RubyCAS::Server::Core
  describe RubyCAS::Server::Core::Tickets do
    let(:client_hostname) { 'myhost.test' }
    let(:username) { 'myuser' }
    let(:service) { 'https://myservice.test' }

    describe '.generate_login_ticket(client_hostname)' do
      let(:lt) { Tickets.generate_login_ticket(client_hostname) }

      before do
        Persistence.stub(:save_ticket).and_return(true)
      end

      it "should set the client_hostname" do
        lt.client_hostname.should == client_hostname
      end
    end

    describe ".generate_ticket_granting_ticket(username, extra_attributes = {})" do
      let(:tgt) { Tickets.generate_ticket_granting_ticket(username, client_hostname) }

      it "should return a TicketGrantingTicket" do
        tgt.class.should == Tickets::TicketGrantingTicket
      end

      it "should set the tgt's ticket string" do
        tgt.ticket.should_not be_nil
      end

      it "should generate a ticket string starting with 'TGC'" do
        tgt.ticket.should match /^TGC/
      end

      it "should set the tgt's username string" do
        tgt.username.should == username
      end

      it "should set the tgt's client_hostname" do
        tgt.client_hostname.should == client_hostname
      end
    end

    describe '.ticket_granting_ticket_valid?(tgt_string)' do
      let(:tgt_string) { 'TGT-ABCD1234' }
      let(:tgt) { Tickets::TicketGrantingTicket.new }

      it 'must satisfy our expectations' do
        Persistence.should_receive(:load_tgt).with(tgt_string).and_return(tgt)
        tgt.should_receive(:valid?).and_return(true)
        Tickets.ticket_granting_ticket_valid?(tgt_string)
      end

      it 'must raise an error if no ticket is specified' do
        expect{ Tickets.ticket_granting_ticket_valid?('') }.to raise_error ArgumentError
      end
    end

    describe ".generate_service_ticket(service, username, tgt)" do
      let(:tgt) { Tickets.generate_ticket_granting_ticket(username, client_hostname) }
      let(:st) { Tickets.generate_service_ticket(service, username, tgt, client_hostname) }

      it "should return a ServiceTicket" do
        st.class.should == Tickets::ServiceTicket
      end

      it "should not include the service identifer in the ticket string" do
        st.ticket.should_not match /#{service}/
      end

      it "should not mark the ST as consumed" do
        st.consumed.should be_nil
      end

      it "must generate a ticket that starts with 'ST-'" do
        st.ticket.should match /^ST-/
      end

      it "should assoicate the ST with the supplied TGT" do
        st.ticket_granting_ticket.id.should == tgt.id
      end
    end

    describe ".generate_proxy_ticket(target_service, pgt)" do
      it "should return a ProxyGrantingTicket" do
        pending("Proxy ticket is not implemented yet")
      end

      it "should not consume the generated ticket" do
        pending("Proxy ticket is not implemented yet")
      end

      it "should start the ticket string with PT-" do
        pending("Proxy ticket is not implemented yet")
      end
    end
  end
end
