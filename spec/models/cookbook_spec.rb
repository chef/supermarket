require 'spec_helper'

describe Cookbook do
  describe '#to_param' do
    it "returns the cookbook's name downcased and parameterized" do
      cookbook = Cookbook.new(name: 'Spicy Curry')
      expect(cookbook.to_param).to eql('spicy-curry')
    end
  end
end
