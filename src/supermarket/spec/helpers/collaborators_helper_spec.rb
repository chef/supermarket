require 'spec_helper'

describe CollaboratorsHelper do
  let!(:cookbook) { create(:cookbook) }
  let!(:collaborator1) { create(:cookbook_collaborator, resourceable: cookbook) }

  let(:group) { create(:group) }
  let!(:collaborator2) { create(:cookbook_collaborator, resourceable: cookbook, group: group) }
  let!(:collaborator3) { create(:cookbook_collaborator, resourceable: cookbook, group: group) }

  before do
    expect(cookbook.collaborators).to_not be_empty
  end

  describe '#non_group_collaborators' do
    it 'finds all collaborators not associated with a group' do
      expect(helper.non_group_collaborators(cookbook.collaborators)).to include(collaborator1)
      expect(helper.non_group_collaborators(cookbook.collaborators)).to_not include(collaborator2)
      expect(helper.non_group_collaborators(cookbook.collaborators)).to_not include(collaborator3)
    end
  end

  describe '#group_collaborators' do
    it 'finds all collaborators associated with a group' do
      expect(helper.group_collaborators(cookbook.collaborators, group)).to include(collaborator2)
      expect(helper.group_collaborators(cookbook.collaborators, group)).to include(collaborator3)
      expect(helper.group_collaborators(cookbook.collaborators, group)).to_not include(collaborator1)
    end
  end

  describe '#collaborator_removal_text' do
    let(:sally) { create(:user) }
    let(:hank) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: sally) }

    before do
      create(:cookbook_collaborator, resourceable: cookbook, user: hank)
    end

    it 'returns "Remove Collaborator" if you are the owner' do
      allow(helper).to receive(:current_user) { sally }
      expect(helper.collaborator_removal_text(cookbook.owner)).to eql('Remove Collaborator')
    end

    it 'returns "Remove Myself" if you are a collaborator' do
      allow(helper).to receive(:current_user) { hank }
      expect(helper.collaborator_removal_text(cookbook.owner)).to eql('Remove Myself')
    end
  end
end
