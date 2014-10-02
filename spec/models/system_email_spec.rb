require 'spec_helper'

describe SystemEmail do
  context 'associations' do
    it { should have_many(:email_preferences) }
    it { should have_many(:subscribed_users) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
end
