require 'spec_helper'

describe Group do
  context 'associations' do
    it { should have_many(:group_members) }
    it { should have_many(:members) }
    it { should have_many(:group_resources) }
  end

  it 'requires a name' do
    group = Group.new(name: '')
    expect(group).to_not be_valid
  end

  it 'requires a unique name' do
    group1 = create(:group)

    group2 = Group.new(name: group1.name)
    expect(group2).to_not be_valid
  end

  describe '.search' do
    let(:a_group) { create(:group, name: 'a-group') }
    let(:ab_group) { create(:group, name: 'a-group-2') }
    let(:c_group) { create(:group, name: 'c-group') }

    it 'returns groups with a similar name' do
      expect(Group.search('a')).to include(a_group, ab_group)
      expect(Group.search('a')).to_not include(c_group)
    end
  end
end
