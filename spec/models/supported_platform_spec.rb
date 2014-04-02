require 'spec_helper'

describe SupportedPlatform do
  context 'validations' do
    it 'allows ">= 0.0.0" as a version constraint' do
      platform = SupportedPlatform.new(version_constraint: '>= 0.0.0')

      platform.valid?

      expect(platform.errors[:version_constraint]).to be_empty
    end

    it 'does not allow "snarfle" as a version constraint' do
      platform = SupportedPlatform.new(version_constraint: 'snarfle')

      platform.valid?

      expect(platform.errors[:version_constraint]).
        to include('is not a valid Chef version constraint')
    end

    it 'does not allow blank version constraints' do
      platform = SupportedPlatform.new(version_constraint: '')

      platform.valid?

      expect(platform.errors[:version_constraint]).
        to include('is not a valid Chef version constraint')
    end
  end
end
