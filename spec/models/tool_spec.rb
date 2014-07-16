require 'spec_helper'

describe Tool do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
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
end
