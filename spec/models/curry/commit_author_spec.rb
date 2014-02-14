require 'spec_helper'

describe Curry::CommitAuthor do

  describe 'database default values' do

    it 'sets signed_cla to false' do
      commit_author = Curry::CommitAuthor.create!

      expect(commit_author.reload.signed_cla).to eql(false)
    end

  end

  describe '#sign_cla!' do
    it 'updates signed_cla to true' do
      commit_author = create(:commit_author, signed_cla: false)
      commit_author.sign_cla!

      expect(commit_author.reload.signed_cla).to be_true
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
