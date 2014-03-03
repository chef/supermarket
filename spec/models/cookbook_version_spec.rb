require 'spec_helper'

describe CookbookVersion do
  context 'associations' do
    it { should belong_to(:cookbook) }
  end

  context 'validations' do
    it { should validate_presence_of(:license) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:cookbook_id) }
  end

  context '#to_param' do
    it 'returns the version in underscore format' do
      cookbook_version = CookbookVersion.new(version: '1.1.0')

      expect(cookbook_version.to_param).to eql('1_1_0')
    end
  end
end
