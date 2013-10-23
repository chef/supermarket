require 'spec_helper'

describe IclaSignature do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
  end
end
