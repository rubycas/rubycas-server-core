require "spec_helper"

describe RubyCAS::Server::Core::Tickets::Validations do

  before do
    RubyCAS::Server::Core.setup("spec/config/config.yml")
    @generations = Class.new
    @generations.extend(RubyCAS::Server::Core::Tickets::Generations)
    @validations = Class.new
    @validations.extend(RubyCAS::Server::Core::Tickets::Validations)
  end

  describe "validate login ticket" do
    it "should validate login ticket" do
      @lt = @generations.generate_login_ticket(@client_hostname)
      success, error = @validations.validate_login_ticket(@lt.ticket)
      success.should be_truthy
      error.should be_nil
    end
  end
  describe "validations"
    describe "#validate_login_ticket" do
      context "with valid ticket" do
        it "should validate login ticket" do
          @lt = @generations.generate_login_ticket(@client_hostname)
          success, error = @validations.validate_login_ticket(@lt.ticket)
          success.should be_truthy
          error.should be_nil
        end
      end

      context "with invalid ticket" do
        it "should not validate login ticket" do
          @lt = @generations.generate_login_ticket(@client_hostname)
          success, error = @validations.validate_login_ticket("#{@lt.ticket}random")
          expect(success).to be false
          expect(error).not_to be nil
        end
      end
    end

    describe "#validate_ticket_granting_ticket(username, extra_attributes = {})" do
      before do
        @username = 'myuser'
        @client_hostname = "myhost.test"
        @tgt = @generations.generate_ticket_granting_ticket(@username, @client_hostname)
      end

      context "with valid tgt" do
        it "should validate ticket granting ticket" do
          success, error = @validations.validate_ticket_granting_ticket(@tgt.ticket)
          expect(success).to eq @tgt
          expect(error).to eq nil
        end
      end

      context "with invalid gt" do
        it "should not validate ticket granting ticket" do
          success, error = @validations.validate_ticket_granting_ticket("#{@tgt.ticket}random")
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
          @tgt = @generations.generate_ticket_granting_ticket(@username, @client_hostname)
          @st = @generations.generate_service_ticket(@service, @username, @tgt, @client_hostname)
        end

        it "should validate service ticket" do
          success, error = @validations.validate_service_ticket(@service, @st.ticket)
          expect(success).to eq true
          expect(error).to be nil
        end
      end

      context "with invalid ticket" do
        before do
          @username = 'testuser'
          @client_hostname = "myhost.test"
          @service = 'myservice.test'
          @tgt = @generations.generate_ticket_granting_ticket(@username, @client_hostname)
          @st = @generations.generate_service_ticket(@service, @username, @tgt, @client_hostname)
        end

        it "does not validate service ticket (throws an error)" do
          _, error = @validations.validate_service_ticket(@service, "#{@st.ticket}-random_string")
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
