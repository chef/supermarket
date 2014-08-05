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

  describe '#contributor_removal_text' do
    let(:sally) { create(:user) }
    let(:hank) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: sally) }

    before do
      create(:cookbook_collaborator, resourceable: cookbook, user: hank)
    end

    it 'returns "Remove Contributor" if you are the owner' do
      allow(helper).to receive(:current_user) { sally }
      expect(helper.contributor_removal_text(cookbook.owner)).to eql('Remove Contributor')
    end

    it 'returns "Remove Myself" if you are a contributor' do
      allow(helper).to receive(:current_user) { hank }
      expect(helper.contributor_removal_text(cookbook.owner)).to eql('Remove Myself')
    end
  end
end
