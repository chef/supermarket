require 'spec_helper'

describe Tool do
  context 'associations' do
    it { should belong_to(:owner) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should ensure_inclusion_of(:type).in_array(Tool::ALLOWED_TYPES) }

    it 'validates the uniqueness of name' do
      create(:tool)
      expect(subject).to validate_uniqueness_of(:name).case_insensitive
    end
  end

  describe '#lowercase_name' do
    it 'is set as part of the saving lifecycle' do
      tool = Tool.new(name: 'Dingus')
      expect { tool.save }.to change(tool, :lowercase_name).from(nil).to('dingus')
    end
  end

  describe '.with_name' do
    it 'is case-insensitive' do
      tool = create(:tool, name: 'DINGUS')
      expect(Tool.with_name('dinGus')).to include(tool)
    end

    it 'can locate multiple tools at once' do
      tool = create(:tool, name: 'DINGUS')
      mytool = create(:tool, name: 'OH YES')
      scope = Tool.with_name(['dingus', 'oh yes'])
      expect(scope).to include(tool, mytool)
    end
  end

  describe '.others_from_this_owner' do
    it 'should find other tools by this owner' do
      user = create(:user)
      tool = create(:tool, name: 'DINGUS', owner: user)
      mytool = create(:tool, name: 'OH YES', owner: user)
      expect(tool.others_from_this_owner.to_a).to eql([mytool])
    end
  end
end
