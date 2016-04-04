require 'spec_helper'

describe CookbookFollower do
  context 'associations' do
    it { should belong_to(:cookbook) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    it 'validates the uniquness of cookbook_id scoped to user_id' do
      create(:cookbook_follower)

      expect(subject).to validate_uniqueness_of(:cookbook_id).scoped_to(:user_id)
    end

    it { should validate_presence_of(:cookbook) }
    it { should validate_presence_of(:user) }
  end
end
