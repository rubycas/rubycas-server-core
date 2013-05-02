require 'spec_helper'

module RubyCAS::Server::Core::Tickets
  describe NilTicket do
    describe '.fields' do
      it 'must return an empty array' do
        described_class.fields.should == []
      end
    end

    describe '#attributes' do
      it 'must return an empty hash' do
        subject.attributes.should == {}
      end
    end

    describe '#present?' do
      it 'must return false' do
        subject.present?.should be false
      end
    end

    describe '#save' do
      it 'must return false' do
        subject.save.should be false
      end
    end

    describe '#is_a?(other)' do
      it 'must return true when passed Ticket' do
        subject.is_a?(Ticket).should be true
      end

      it 'must return true when passed NilTicket' do
        subject.is_a?(NilTicket).should be true
      end

      it 'must return false otherwise' do
        subject.is_a?(Fixnum).should be false
      end
    end

    describe '#valid?' do
      it 'must return false' do
        subject.valid?.should be false
      end
    end
  end
end
