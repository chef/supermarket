require 'spec_helper'

describe CookbookCollaborator do
  context 'associations' do
    it { should belong_to(:cookbook) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:cookbook) }

    it 'is unique to a cookbook and user' do
      user = create(:user)
      cookbook = create(:cookbook)
      cookbook_collaborator = CookbookCollaborator.create! cookbook: cookbook, user: user
      expect do
        CookbookCollaborator.create! cookbook: cookbook, user: user
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it 'finds itself based on a cookbook and user' do
    user = create(:user)
    cookbook = create(:cookbook)
    cookbook_collaborator = create(:cookbook_collaborator, cookbook: cookbook, user: user)
    expect(CookbookCollaborator.with_cookbook_and_user(cookbook, user)).to eql(cookbook_collaborator)
  end

  it 'facilitates the transfer of ownership' do
    sally = create(:user)
    hank = create(:user)
    cookbook = create(:cookbook, owner: sally)
    cookbook_collaborator = create(:cookbook_collaborator, cookbook: cookbook, user: hank)
    cookbook_collaborator.transfer_ownership
    expect(cookbook.owner).to eql(hank)
    expect(cookbook.collaborators).to include(sally)
    expect(cookbook.collaborators).to_not include(hank)
  end
end
