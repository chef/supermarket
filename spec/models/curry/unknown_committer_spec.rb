require 'spec_helper'

describe Curry::UnknownCommitter do

  describe '.with_known_email' do

    it 'returns only committers whose email address is known' do
      known = create(:unknown_committer, email: 'known')
      unknown = create(:unknown_committer, email: nil)

      expect(Curry::UnknownCommitter.with_known_email).to include(known)
      expect(Curry::UnknownCommitter.with_known_email).to_not include(unknown)
    end

  end

  describe '.with_known_login' do

    it 'returns only committers whose GitHub login is known' do
      known = create(:unknown_committer, login: 'known')
      unknown = create(:unknown_committer, login: nil)

      expect(Curry::UnknownCommitter.with_known_login).to include(known)
      expect(Curry::UnknownCommitter.with_known_login).to_not include(unknown)
    end

  end

end
