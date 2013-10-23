require 'spec_helper'

describe Account do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:oauth_token) }
    it { should validate_presence_of(:oauth_secret) }
    it { should validate_presence_of(:oauth_expires) }
  end
end
