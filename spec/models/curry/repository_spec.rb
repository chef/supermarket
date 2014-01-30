require 'spec_helper'

describe Curry::Repository do
  context 'validations' do
    it { should validate_presence_of(:owner) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:callback_url) }
  end
end
