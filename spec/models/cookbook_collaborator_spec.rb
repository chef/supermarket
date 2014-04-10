require 'spec_helper'

describe CookbookCollaborator do
  context 'associations' do
    it { should belong_to(:cookbook) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:cookbook) }

    it 'should require a user with an ICLA' do
      c = create(:cookbook)
      u = create(:user)
      v = create(:user)
      create(:icla_signature, user: v)

      cc = CookbookCollaborator.new cookbook: c
      expect(cc).to_not be_valid
      expect(cc.errors[:user]).to_not be_empty
      expect(cc.errors[:user].join).to match(/can't be blank/)

      cc.user = u
      expect(cc).to_not be_valid
      expect(cc.errors[:user]).to_not be_empty
      expect(cc.errors[:user].join).to match(/ICLA/)

      cc.user = v
      expect(cc).to be_valid
      expect(cc.errors[:user]).to be_empty
    end
  end

  it 'finds itself based on a cookbook and user' do
    u = create(:user)
    c = create(:cookbook)
    create(:icla_signature, user: u)
    cc = CookbookCollaborator.create! cookbook: c, user: u
    expect(CookbookCollaborator.with_cookbook_and_user(c, u)).to eql(cc)
  end
end
