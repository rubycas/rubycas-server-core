require 'spec_helper'

module RubyCAS::Server::Core
  describe Persistence do
    describe '.adapter_named' do
      let(:name) { :awesome_adapter }
      let(:klass) { Class.new }

      it 'must raise an error when an un-registered name is supplied' do
        expect{ Persistence.adapter_named(:garbage) }.to raise_error Persistence::AdapterNotRegisteredError
      end

      it 'must return the class registered to that name' do
        Persistence.register_adapter(name, klass)
        Persistence.adapter_named(name.to_s).should eq klass
      end
    end

    describe '.register_adapter(adapter_name, handler)' do
      let(:klass) { Class.new }
      let(:name) { :super_awesome }

      before do
        Persistence.register_adapter(name, klass)
      end

      it 'must allow us to look up the adapter class by giving the name' do
        Persistence.adapter_named(name).should eq klass
      end
    end

    describe '.load_ticket_granting_ticket(tgt_string)' do
      it 'must raise an error since it will get replaced by our various implementations' do
        expect{
          Persistence.load_ticket_granting_ticket('TGT-ABCD')
        }.to raise_error NotImplementedError
      end
    end
  end
end
