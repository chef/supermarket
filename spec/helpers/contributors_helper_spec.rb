require 'spec_helper'

describe ContributorsHelper do
  let(:user) { create(:user) }

  describe '#remove_contributor_link_for' do
    it 'returns a remove myself contributor link when the current user owns the contributor' do
      allow(helper).to receive(:current_user) { user }
      contributor = create(:contributor, user: user)

      expect(helper.remove_contributor_link_for(contributor)).to match(/<a.*remove_self/)
    end

    it 'returns a remove contributor link  when the current user owns the contributor' do
      allow(helper).to receive(:current_user) { user }
      contributor = create(:contributor)

      expect(helper.remove_contributor_link_for(contributor)).to match(/<a.*remove_contributor/)
    end
  end
end
