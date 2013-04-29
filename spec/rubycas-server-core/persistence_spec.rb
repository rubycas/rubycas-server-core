require 'spec_helper'

module RubyCAS::Server::Core
  describe Persistence, focus: true do
    let(:name) { :awesome_adapter }
    let(:klass) { double }

    before do
      Persistence.register_adapter(name, klass)
    end

    describe '.setup(config)' do
      let(:config) { {
        adapter: name.to_s,
        address: '127.0.0.1',
        password: 'super'
      } }

      before do
        klass.should_receive(:setup).with(config)
      end

      it 'must pass the config on to the selected adapter' do
        Persistence.setup(config)
      end
    end

    describe '.adapter_named' do
      it 'must raise an error when an un-registered name is supplied' do
        expect{ Persistence.adapter_named(:garbage) }.to raise_error Persistence::AdapterNotRegisteredError
      end

      it 'must return the class registered to that name' do
        Persistence.adapter_named(name.to_s).should eq klass
      end
    end

    describe '.register_adapter(adapter_name, handler)' do
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
