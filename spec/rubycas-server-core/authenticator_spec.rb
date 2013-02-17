require 'spec_helper'

describe RubyCAS::Server::Core::Authenticator do
  it "should raise" do
    expect { subject.configure("String") }.to raise_error(ArgumentError)
  end

  describe "Initialize authenticator configuration" do
    before do
      subject.configure({:test => "value"})
    end
    it "should return correct options" do
      subject.options[:test].should eq("value")
    end

    it "should initialize extra attributes" do
      subject.extra_attributes.should be_kind_of(Hash)
      subject.extra_attributes.should be_empty
    end

  end

end
