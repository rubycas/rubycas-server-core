require "spec_helper"

describe Hash do
  it "should convert all keys into symbol" do
    test_hash = {"a" => 1, "b" => "test", :c => {:d => {:r => "test"}}}
    result = Hash.symbolize_keys(test_hash)
    result[:a].should eq(1)
    result[:b].should eq("test")
    result[:c][:d][:r].should eq("test")
  end
end
