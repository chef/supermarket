require 'spec_helper'

describe Email do
  context 'concerns' do
    it { should be_a(Tokenable) }
  end

  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  context 'callbacks' do
    it 'generates a confirmation token' do
      email = create(:email)
      expect(email.confirmation_token).to_not be_nil
    end
  end

  context 'instance methods' do
    describe '#confirmed?' do
      it 'is true when the email is confirmed' do
        email = build(:email)
        expect(email.confirmed?).to be_true
      end

      it 'is false when the email is not confirmed' do
        email = build(:email, confirmed_at: nil)
        expect(email.confirmed?).to be_false
      end
    end
  end
end
