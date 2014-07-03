require 'spec_helper'

describe Curry::CommitAuthor do
  describe 'validations' do
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:login) }
  end

  describe 'database default values' do

    it 'sets authorized_to_contribute to false' do
      commit_author = Curry::CommitAuthor.create!

      expect(commit_author.reload.authorized_to_contribute).to eql(false)
    end

  end

  describe '#sign_cla!' do
    it 'updates authorized_to_contribute to true' do
      commit_author = create(:commit_author, authorized_to_contribute: false)
      commit_author.sign_cla!

      expect(commit_author.reload.authorized_to_contribute).to be_true
    end
  end

  describe '.with_known_email' do

    it 'returns only commit authors whose email address is known' do
      known = create(:commit_author, email: 'known')
      unknown = create(:commit_author, email: nil)

      expect(Curry::CommitAuthor.with_known_email).to include(known)
      expect(Curry::CommitAuthor.with_known_email).to_not include(unknown)
    end

  end

  describe '.with_known_login' do

    it 'returns only commit authors whose GitHub login is known' do
      known = create(:commit_author, login: 'known')
      unknown = create(:commit_author, login: nil)

      expect(Curry::CommitAuthor.with_known_login).to include(known)
      expect(Curry::CommitAuthor.with_known_login).to_not include(unknown)
    end
  end
end
