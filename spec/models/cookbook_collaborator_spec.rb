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
    cookbook_collaborator = CookbookCollaborator.create! cookbook: cookbook, user: user
    expect(CookbookCollaborator.with_cookbook_and_user(cookbook, user)).to eql(cookbook_collaborator)
  end
end
