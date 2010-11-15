require 'spec_helper'
require 'nokogiri/diff'

describe Nokogiri::Diff do
  it "should have a VERSION constant" do
    Nokogiri::Diff.const_get('VERSION').should_not be_empty
  end
end
