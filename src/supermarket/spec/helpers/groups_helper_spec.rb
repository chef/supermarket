require 'spec_helper'

describe GroupsHelper do
  let(:group) { create(:group) }
  let(:admin_user) { create(:user) }

  let!(:admin_member) do
    create(:admin_group_member, user: admin_user, group: group)
  end

  let(:user) { create(:user) }

  let!(:member) do
    create(:group_member, user: user, group: group)
  end

  describe '#admin_member?' do
    context 'when then user is an admin member' do
      it 'returns true' do
        expect(helper.admin_member?(admin_user, group)).to eq(true)
      end
    end

    context 'when the user is NOT an admin member' do
      it 'returns false' do
        expect(helper.admin_member?(user, group)).to eq(false)
      end
    end
  end

  describe '#admin_members' do
    it 'returns the admin members' do
      expect(helper.admin_members(group)).to include(admin_member)
      expect(helper.admin_members(group)).to_not include(member)
    end
  end

  describe '#group_resources' do
    let!(:cookbook) { create(:cookbook) }
    let!(:group_resource) { create(:group_resource, resourceable: cookbook, group: group) }

    before do
      expect(cookbook.group_resources).to include(group_resource)
    end

    it 'includes resources associated with the group' do
      expect(helper.group_resourceables(group)).to include(cookbook)
    end
  end
end
