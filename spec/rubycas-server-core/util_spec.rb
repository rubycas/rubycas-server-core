require 'spec_helper'

describe RubyCAS::Server::Core::Util do
  before(:all) do
    Util = RubyCAS::Server::Core::Util
  end

  describe '.clean_service_url' do
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
end
