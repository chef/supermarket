require 'spec_helper'

describe CollaboratorsHelper do
  let(:jimmy) { create(:user) }
  let(:hank) { create(:user) }
  let(:sally) { create(:user) }
  let(:fanny) { create(:user) }
  let(:cookbook) { create(:cookbook, owner: sally) }

  before do
    create(:icla_signature, user: hank)
    create(:icla_signature, user: fanny)
    create(:cookbook_collaborator, cookbook: cookbook, user: hank)
    create(:cookbook_collaborator, cookbook: cookbook, user: fanny)
  end

  describe '#owner?' do
    it 'should be true for the owner of a cookbook' do
      helper.stub(:current_user) { sally }
      expect(helper.owner?(cookbook)).to be_true
    end

    it 'should be false for anyone else' do
      helper.stub(:current_user) { jimmy }
      expect(helper.owner?(cookbook)).to be_false
    end
  end

  describe '#collaborator?' do
    it 'should be true when the current user is a collaborator and matches the collaborator in question' do
      helper.stub(:current_user) { hank }
      expect(helper.collaborator?(cookbook, hank)).to be_true
    end

    it 'should be false when the current user is a collaborator and does not match the collaborator in question' do
      helper.stub(:current_user) { fanny }
      expect(helper.collaborator?(cookbook, hank)).to be_false
    end

    it 'should be false when the current user is not a collaborator' do
      helper.stub(:current_user) { jimmy }
      expect(helper.collaborator?(cookbook, hank)).to be_false
    end
  end
end
