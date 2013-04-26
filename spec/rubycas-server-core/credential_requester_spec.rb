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
      controller.should_receive(:user_not_logged_in).with("LT-123ABC", nil)
    end

    it 'must satisfy our expectations' do
      subject.process!(params, cookies)
    end
  end

  describe 'already logged in' do
    describe 'with a valid session' do
      let(:service) { 'https://service.test.com' }
      let(:st) { 'ST-1234DCBA' }
      let(:params) { {
        'service' => service
      } }
      let(:cookies) { {
        'tgt' => "TGT-4321ABCD"
      } }

      before do
        RubyCAS::Server::Core::Tickets.should_receive(:ticket_granting_ticket_valid?).with('TGT-4321ABCD').and_return(true)
        RubyCAS::Server::Core::Tickets.stub(:generate_service_ticket).with(service, 'TGT-4321ABCD') {
          OpenStruct.new({ticket: st})
        }

        controller.should_receive(:user_logged_in).with("#{service}?ticket=#{st}")
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end

    describe 'with an invalid session' do
      let(:service) { 'https://service.test.com' }
      let(:params) { {
        'service' => service
      } }
      let(:cookies) { {
        'tgt' => "TGT-4321ABCD"
      } }
      let(:message) { 'Error message' }

      before do
        RubyCAS::Server::Core::Tickets.should_receive(:ticket_granting_ticket_valid?).with('TGT-4321ABCD').and_return([false, message])
        RubyCAS::Server::Core::Tickets.stub(:generate_login_ticket) {
          OpenStruct.new({ticket: 'LT-123ABC'})
        }

        controller.should_receive(:user_not_logged_in).with("LT-123ABC", message)
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end
  end

  describe 'with gateway param set to true' do
    let(:service) { 'https://service.test.com' }
    let(:params) { {
      'service' => service,
      'gateway' => true
    } }
    let(:cookies) { {
      'tgt' => "TGT-4321ABCD"
    } }
    let(:st) { 'ST-1234DCBA' }

    describe 'with a valid session' do
      before do
        RubyCAS::Server::Core::Tickets.should_receive(:ticket_granting_ticket_valid?).with('TGT-4321ABCD').and_return(true)
        RubyCAS::Server::Core::Tickets.stub(:generate_service_ticket).with(service, 'TGT-4321ABCD') {
          OpenStruct.new({ticket: st})
        }

        controller.should_receive(:user_logged_in).with("#{service}?ticket=#{st}")
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end

    describe 'with an invalid session' do
      let(:message) { 'Error message' }

      before do
        RubyCAS::Server::Core::Tickets.
          stub(:ticket_granting_ticket_valid?).
          with('TGT-4321ABCD').
          and_return(false, message)

        controller.should_receive(:user_logged_in).with("#{service}")
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end

    describe 'with no session' do
      let(:cookies) { {} }

      before do
        RubyCAS::Server::Core::Tickets.should_not_receive(:ticket_granting_ticket_valid?)

        controller.should_receive(:user_logged_in).with("#{service}")
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end

    describe 'with no service URL supplied' do
      let(:params) { {
        'gateway' => true
      } }

      before do
        # the tgt status here doesn't matter
        RubyCAS::Server::Core::Tickets.stub(:ticket_granting_ticket_valid?).with('TGT-4321ABCD').and_return(true)
        RubyCAS::Server::Core::Tickets.stub(:generate_login_ticket) {
          OpenStruct.new({ticket: 'LT-123ABC'})
        }
        controller.should_receive(:user_not_logged_in).with("LT-123ABC", nil)
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end
  end

    # renew param
end
