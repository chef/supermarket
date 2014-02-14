require 'spec_helper'

describe Curry::CommitAuthor do

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
