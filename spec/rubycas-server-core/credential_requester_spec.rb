require 'spec_helper'

describe RubyCAS::Server::Core::CredentialRequester do
  let(:controller) { double("Controller") }
  subject { described_class.new(controller) }

  describe 'new login' do
    let(:params) { {} }
    let(:cookies) { {} }

    before do
      RubyCAS::Server::Core::Tickets.stub(:generate_login_ticket) {
        OpenStruct.new({ticket: 'LT-123ABC'})
      }
      controller.should_receive(:user_not_logged_in).with("LT-123ABC")
    end

    it 'must satisfy our expectations' do
      subject.process!(params, cookies)
    end
  end

  # already logged in
    # if session is good
      # update last_used on session
      # send user_logged_in(target_service)
    # if session is invalid
      # ensure session is destroyed
      # generate/persist new login ticket
      # send user_not_logged_in(ticket_string)

  # gateway param
  # forced renew param
end
