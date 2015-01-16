require "spec_helper"

describe RubyCAS::Server::Core::Tickets::Validations do
  before do
   RubyCAS::Server::Core.setup("spec/config/config.yml")
   klass = Class.new {
      include RubyCAS::Server::Core::Tickets
      include RubyCAS::Server::Core::Tickets::Validations
   }
   @cas = klass.new
   @client_hostname = "myhost.test"
   Tickets = RubyCAS::Server::Core::Tickets
  end

  describe "validate login ticket" do
    it "should validate login ticket" do
      @lt = Tickets.generate_login_ticket(@client_hostname)
      success, error = @cas.validate_login_ticket(@lt.ticket)
      success.should be_truthy
      error.should be_nil
    end
  end

  describe "validate ticket_granting_ticket(username, extra_attributes = {})" do
    before do
      @username = 'myuser'
      @client_hostname = "myhost.test"
      @tgt = Tickets.generate_ticket_granting_ticket(@username, @client_hostname)
    end

    it "should validate ticket granting ticket" do
      success, error = @cas.validate_ticket_granting_ticket(@tgt.ticket)
      success.should be_truthy
      error.should be_nil
    end
  end

  describe "validate service_ticket(service, username, tgt)" do
    before do
      @username = 'testuser'
      @client_hostname = "myhost.test"
      @service = 'myservice.test'
      @tgt = Tickets.generate_ticket_granting_ticket(@username, @client_hostname)
      @st = Tickets.generate_service_ticket(@service, @username, @tgt, @client_hostname)
    end

    it "should validate service ticket" do
      success, error = @cas.validate_service_ticket(@service, @st.ticket)
      success.should be_truthy
      error.should be_nil
    end
  end

  describe "validate proxy_ticket(target_service, pgt)" do

    before do
      pending("Proxy ticket is not yet implemented")
    end

  end

end
