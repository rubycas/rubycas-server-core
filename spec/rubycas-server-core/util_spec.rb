require 'spec_helper'

describe RubyCAS::Server::Core::Util do
  before(:all) do
    Util = RubyCAS::Server::Core::Util
  end

  describe '.build_ticketed_url(service, ticket)' do
    let(:ticket) { 'ST-12345EDCBA' }
    let(:service) { 'http://www.google.com' }

    it 'must add the ticket to our query string when none was present' do
      ticketed = Util.build_ticketed_url(service, ticket)
      expect(ticketed).to eq("#{service}?ticket=#{ticket}")
    end

    it 'must add the ticket to the query string when one is already present' do
      ticketed = Util.build_ticketed_url("#{service}?param=value", ticket)
      expect(ticketed).to eq("#{service}?param=value&ticket=#{ticket}")
    end

    it 'must return an empty string when no service url is present' do
      expect(Util.build_ticketed_url('', ticket)).to eq('')
    end

    it 'must return an empty string when service url is nil' do
      expect(Util.build_ticketed_url(nil, ticket)).to eq('')
    end
  end

  describe '.clean_service_url' do
    it 'must return an empty string when an empty value is passed' do
      expect(Util.clean_service_url('')).to eq('')
    end

    it 'must return an empty string when an nil value is passed' do
      expect(Util.clean_service_url(nil)).to eq('')
    end

    it 'must strip off a trailing ?' do
      cleaned = Util.clean_service_url('http://www.google.com?')
      expect(cleaned).to eq('http://www.google.com')
    end

    it 'must strip off a trailing &' do
      cleaned = Util.clean_service_url('http://www.google.com?param=value&')
      expect(cleaned).to eq('http://www.google.com?param=value')
    end

    it 'must remove empty params' do
      cleaned = Util.clean_service_url('http://www.google.com?&')
      expect(cleaned).to eq('http://www.google.com')
    end

    %w{service ticket gateway renew}.each do |param|
      it "must remove any '#{param}' params" do
        url = "http://www.google.com?#{param}=value"
        cleaned = Util.clean_service_url(url)
        expect(cleaned).to eq('http://www.google.com')
      end
    end

    it 'must leave other params intact after removing our sensitive params' do
      url = "http://www.google.com?something=booyah&gateway=true&param=value"
      cleaned = Util.clean_service_url(url)
      expect(cleaned).to eq('http://www.google.com?something=booyah&param=value')
    end
  end

  describe '.random(length = 29' do
    context 'when max length is not passed in' do
      it 'should return a random string of length 29' do
        Util.random_string.length.should == 29
      end
    end

    context 'when max length is passed in' do
      it 'should return a random string of the desired length' do
        Util.random_string(30).length.should == 30
        (Util.random_string(30) =~ /(\w|-){29}/).should eq(0)
      end
    end

    it 'should return a random string' do
      random_string = Util.random_string
      another_random_string = Util.random_string
      random_string.should_not == another_random_string
    end
  end
end
