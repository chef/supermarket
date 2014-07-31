require 'spec_helper'

describe Collaborator do
  context 'associations' do
    it { should belong_to(:resourceable) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:resourceable) }

    it 'validates the uniqueness of resourceable id scoped to user id and resourceable type' do
      cookbook = create(:cookbook)
      tool = create(:tool)
      user = create(:user)

      original_cookbook_collaborator = Collaborator.create(user: user, resourceable: cookbook)
      original_tool_collaborator = Collaborator.create(user: user, resourceable: tool)
      duplicate_cookbook_collaborator = Collaborator.create(user: user, resourceable: cookbook)

      expect(original_cookbook_collaborator.errors[:resourceable_id].size).to be 0
      expect(original_tool_collaborator.errors[:resourceable_id].size).to be 0
      expect(duplicate_cookbook_collaborator.errors[:resourceable_id].size).to be 1
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
