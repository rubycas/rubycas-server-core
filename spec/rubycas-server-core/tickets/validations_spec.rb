require "spec_helper"

describe RubyCAS::Server::Core::Tickets::Validations do
  before(:all) do
    Tickets = RubyCAS::Server::Core::Tickets
  end

  before do
    RubyCAS::Server::Core.setup("spec/config/config.yml")
    klass = Class.new {
      include RubyCAS::Server::Core::Tickets
      include RubyCAS::Server::Core::Tickets::Validations
    }
    @cas = klass.new
    @client_hostname = "myhost.test"
  end

  describe "validations"

    describe "#validate_login_ticket" do
      context "with valid ticket" do
        it "should validate login ticket" do
          @lt = Tickets.generate_login_ticket(@client_hostname)
          success, error = @cas.validate_login_ticket(@lt.ticket)
          success.should be_true
          error.should be_nil
        end
      end

      context "with invalid ticket" do
        it "should not validate login ticket" do
          @lt = Tickets.generate_login_ticket(@client_hostname)
          success, error = @cas.validate_login_ticket("#{@lt.ticket}random")
          expect(success).to be false
          expect(error).not_to be nil
        end
      end
    end

    describe "#validate_ticket_granting_ticket(username, extra_attributes = {})" do
      before do
        @username = 'myuser'
        @client_hostname = "myhost.test"
        @tgt = Tickets.generate_ticket_granting_ticket(@username, @client_hostname)
      end

      context "with valid tgt" do
        it "should validate ticket granting ticket" do
          success, error = @cas.validate_ticket_granting_ticket(@tgt.ticket)
          expect(success).to eq @tgt
          expect(error).to eq nil
        end
      end

      context "with invalid gt" do
        it "should not validate ticket granting ticket" do
          success, error = @cas.validate_ticket_granting_ticket("#{@tgt.ticket}random")
          expect(success).to eq nil
          expect(error).not_to eq nil
        end
      end
    end

    describe "validate service_ticket(service, username, tgt)" do
      context "with valid ticket" do
        before do
          @username = 'testuser'
          @client_hostname = "myhost.test"
          @service = 'myservice.test'
          @tgt = Tickets.generate_ticket_granting_ticket(@username, @client_hostname)
          @st = Tickets.generate_service_ticket(@service, @username, @tgt, @client_hostname)
        end

        it "should validate service ticket" do
          success, error = @cas.validate_service_ticket(@service, @st.ticket)
          expect(success).to eq @st
          expect(error).to be nil
        end
      end

      context "with invalid ticket" do
        before do
          @username = 'testuser'
          @client_hostname = "myhost.test"
          @service = 'myservice.test'
          @tgt = Tickets.generate_ticket_granting_ticket(@username, @client_hostname)
          @st = Tickets.generate_service_ticket(@service, @username, @tgt, @client_hostname)
        end

        it "does not validate service ticket (throws an error)" do
          success, error = @cas.validate_service_ticket(@service, "#{@st.ticket}-random_string")
          expect(error).not_to be nil
        end
      end

    end

    describe "validate proxy_ticket(target_service, pgt)" do

      before do
        pending("Proxy ticket is not yet implemented")
      end

    end

end
