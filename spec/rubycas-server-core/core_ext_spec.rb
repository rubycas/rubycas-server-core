require "spec_helper"

describe String do
  describe '.random(length = 29' do
    context 'when max length is not passed in' do
      it 'should return a random string of length 29' do
        String.random.length.should == 29
      end
    end

    context 'when max length is passed in' do
      it 'should return a random string of the desired length' do
        String.random(30).length.should == 30
        (String.random(30) =~ /(\w|-){29}/).should eq(0)
      end
    end

    it 'should return a random string' do
      random_string = String.random
      another_random_string = String.random
      random_string.should_not == another_random_string
    end
  end
end
