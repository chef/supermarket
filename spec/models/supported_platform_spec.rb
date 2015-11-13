require 'spec_helper'

describe SupportedPlatform do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:version_constraint) }

    it 'allows ">= 0.0.0" as a version constraint' do
      platform = SupportedPlatform.new(version_constraint: '>= 0.0.0')

      platform.valid?

      expect(platform.errors[:version_constraint]).to be_empty
    end

    it 'does not allow "snarfle" as a version constraint' do
      platform = SupportedPlatform.new(version_constraint: 'snarfle')

      expect { platform.valid? }
        .to change { platform.errors[:version_constraint] }
        .to include(/is not a valid Chef version constraint/)
    end

    it 'does not allow blank version constraints' do
      platform = SupportedPlatform.new(version_constraint: '')

      expect { platform.valid? }
        .to change { platform.errors[:version_constraint] }
        .to include(/is not a valid Chef version constraint/)
    end
  end

  context '#for_name_and_version' do
    let(:name) { 'ubuntu' }
    let(:version) { '= 12.04' }

    it 'should return a record when one exists' do
      create(:supported_platform, name: name, version_constraint: version)
      result = SupportedPlatform.for_name_and_version(name, version)
      expect(result.name).to eql('ubuntu')
      expect(result.version_constraint).to eql('= 12.04')
    end

    it 'should return a record when one does not exist' do
      first = SupportedPlatform.where(name: name, version_constraint: version).first
      expect(first).to be_nil
      second = SupportedPlatform.for_name_and_version(name, version)
      expect(second.persisted?).to be true
      expect(second.name).to eql('ubuntu')
      expect(second.version_constraint).to eql('= 12.04')
    end
  end
end
