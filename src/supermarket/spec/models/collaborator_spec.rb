require 'spec_helper'

describe Collaborator do
  context 'associations' do
    it { should belong_to(:resourceable) }
    it { should belong_to(:user) }
    it { should belong_to(:group) }
  end

  context 'validations' do
    let(:cookbook) { create(:cookbook) }
    let(:tool) { create(:tool) }
    let(:user) { create(:user) }

    let!(:original_cookbook_collaborator) { Collaborator.create(user: user, resourceable: cookbook) }
    let!(:original_tool_collaborator) { Collaborator.create(user: user, resourceable: tool) }
    let!(:duplicate_cookbook_collaborator) { Collaborator.create(user: user, resourceable: cookbook) }

    it { should validate_presence_of(:resourceable) }

    context 'of resourceable id' do
      it 'validates uniqueness scoped to user id and resourceable type' do
        expect(original_cookbook_collaborator.errors[:resourceable_id].size).to be 0
        expect(original_tool_collaborator.errors[:resourceable_id].size).to be 0
        expect(duplicate_cookbook_collaborator.errors[:resourceable_id].size).to be 1
      end

      it 'validates uniqueness scoped to user id and resourceable type and group_id' do
        expect(Collaborator.where(user: user, resourceable: cookbook).count).to_not eq 0
        group = create(:group)

        diff_group_collaborator = Collaborator.create(user: user, resourceable: cookbook, group_id: group.id)
        expect(diff_group_collaborator.errors[:resourceable_id].size).to eq 0
      end
    end
  end

  it 'facilitates the transfer of ownership' do
    sally = create(:user)
    hank = create(:user)
    cookbook = create(:cookbook, owner: sally)
    cookbook_collaborator = create(:cookbook_collaborator, resourceable: cookbook, user: hank)
    cookbook_collaborator.transfer_ownership
    expect(cookbook.owner).to eql(hank)
    expect(cookbook.collaborator_users).to include(sally)
    expect(cookbook.collaborator_users).to_not include(hank)
  end
end
