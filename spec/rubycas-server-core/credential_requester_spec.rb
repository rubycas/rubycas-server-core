require 'spec_helper'

describe RubyCAS::Server::Core::CredentialRequester do
  let(:controller) { double("Controller") }
  subject { described_class.new(controller) }

  let(:service) { 'https://service.test.com' }

  let(:tgt) { 'TGT-4321ABCD' }
  let(:st) { 'ST-1234DCBA' }

  let(:message) { 'Error message' }

  describe 'new login' do
    let(:params) { {} }
    let(:cookies) { {} }

    before do
      controller.should_receive(:user_not_logged_in).with(/^LT-\w+/, nil)
    end

    it 'must satisfy our expectations' do
      subject.process!(params, cookies)
    end
  end

  describe 'already logged in' do
    describe 'with a valid session' do
      let(:params) { {
        'service' => service
      } }
      let(:cookies) { {
        'tgt' => tgt
      } }

      before do
        RubyCAS::Server::Core::Tickets.should_receive(:ticket_granting_ticket_valid?).with(tgt).and_return(true)
        RubyCAS::Server::Core::Tickets.stub(:generate_service_ticket).with(service, tgt) {
          OpenStruct.new({ticket: st})
        }

        controller.should_receive(:user_logged_in).with("#{service}?ticket=#{st}")
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end

    describe 'with an invalid session' do
      let(:params) { {
        'service' => service
      } }
      let(:cookies) { {
        'tgt' => tgt
      } }

      before do
        RubyCAS::Server::Core::Tickets.should_receive(:ticket_granting_ticket_valid?).with(tgt).and_return([false, message])

        controller.should_receive(:user_not_logged_in).with(/^LT-\w+/, message)
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end
  end

  describe 'with gateway param set to true' do
    let(:params) { {
      'service' => service,
      'gateway' => true
    } }
    let(:cookies) { {
      'tgt' => tgt
    } }

    describe 'with a valid session' do
      before do
        RubyCAS::Server::Core::Tickets.should_receive(:ticket_granting_ticket_valid?).with(tgt).and_return(true)
        RubyCAS::Server::Core::Tickets.stub(:generate_service_ticket).with(service, tgt) {
          OpenStruct.new({ticket: st})
        }

        controller.should_receive(:user_logged_in).with("#{service}?ticket=#{st}")
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end

    describe 'with an invalid session' do
      before do
        RubyCAS::Server::Core::Tickets.
          stub(:ticket_granting_ticket_valid?).
          with(tgt).
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
        RubyCAS::Server::Core::Tickets.stub(:ticket_granting_ticket_valid?).with(tgt).and_return(true)

        controller.should_receive(:user_not_logged_in).with(/^LT-\w+/, nil)
      end

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end
  end

  describe 'with renew param set' do
    let(:params) { {
      'renew' => true,
      'service' => service
    } }
    let(:cookies) { {
      'tgt' => tgt
    } }

    before do
      RubyCAS::Server::Core::Tickets.stub(:ticket_granting_ticket_valid?).with(tgt).and_return(true)

      controller.should_receive(:user_not_logged_in).with(/^LT-\w+/, nil)
    end

    it 'must satisfy our expectations' do
      subject.process!(params, cookies)
    end

    describe 'and the gateway param set' do
      # force renew any way
      let(:params) { {
        'renew' => true,
        'gateway' => true,
        'service' => service
      } }

      it 'must satisfy our expectations' do
        subject.process!(params, cookies)
      end
    end
  end
end
