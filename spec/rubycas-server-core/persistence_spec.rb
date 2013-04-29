require 'spec_helper'

module RubyCAS::Server::Core
  describe RubyCAS::Server::Core::Persistence do
    describe '.load_tgt(tgt_string)' do
      it 'must raise an error since it will get replaced by our various implementations' do
        expect{
          Persistence.load_tgt('TGT-ABCD')
        }.to raise_error NotImplementedError
      end
    end
  end
end
