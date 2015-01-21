require "spec_helper"

module RubyCAS::Server::Core
  describe RubyCAS::Server::Core::Tickets do
    let(:client_hostname) { 'myhost.test' }
    let(:username) { 'myuser' }
    let(:service) { 'https://myservice.test' }

    before do
      RubyCAS::Server::Core.setup("spec/config/config.yml")
      klass = Class.new {
        include RubyCAS::Server::Core::Tickets
      }
      @cas = klass.new
      @client_hostname = "myhost.test"
    end

    describe '.generate_login_ticket(client_hostname)' do
      let(:lt) { Tickets.generate_login_ticket(client_hostname) }

      it "should return a login ticket" do
        lt.class.should == Tickets::LoginTicket
      end

      it "should set the client_hostname" do
        lt.client_hostname.should == client_hostname
      end

      it "should set the ticket string" do
        lt.ticket.should_not be_nil
      end

      it "should set the ticket string starting with 'LT'" do
        lt.ticket.should match /^LT/
      end

      it "should not mark the ticket as consumed" do
        lt.consumed.should be_nil
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
        fail
      end

      it "should not consume the generated ticket" do
        pending("Proxy ticket is not implemented yet")
        fail
      end

      it "should start the ticket string with PT-" do
        pending("Proxy ticket is not implemented yet")
        fail
      end
    end
  end
end
