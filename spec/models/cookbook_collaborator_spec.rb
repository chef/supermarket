require 'spec_helper'

describe CookbookCollaborator do
  context 'associations' do
    it { should belong_to(:cookbook) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:cookbook) }
    it { should validate_presence_of(:user) }
  end

  it 'finds itself based on a cookbook and user' do
    u = create(:user)
    c = create(:cookbook)
    cc = CookbookCollaborator.create! cookbook: c, user: u
    expect(CookbookCollaborator.with_cookbook_and_user(c, u)).to eql(cc)
  end
end
