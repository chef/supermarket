require 'spec_helper'

describe CookbookDependency do
  context 'validations' do
    it 'allows ">= 0.0.0" as a version constraint' do
      platform = CookbookDependency.new(version_constraint: '>= 0.0.0')

      platform.valid?

      expect(platform.errors[:version_constraint]).to be_empty
    end

    it 'does not allow "snarfle" as a version constraint' do
      platform = CookbookDependency.new(version_constraint: 'snarfle')

      expect { platform.valid? }
        .to change { platform.errors[:version_constraint] }
        .to include(/is not a valid Chef version constraint/)
    end

    it 'does not allow blank version constraints' do
      platform = CookbookDependency.new(version_constraint: '')

      expect { platform.valid? }
        .to change { platform.errors[:version_constraint] }
        .to include(/is not a valid Chef version constraint/)
    end

    it 'must have a unique name and version constraint per CookbookVersion' do
      version = create(:cookbook).cookbook_versions.first

      version.cookbook_dependencies.create!(
        name: 'test',
        version_constraint: '>= 0.0.0'
      )

      expect do
        version.cookbook_dependencies.create!(
          name: 'test',
          version_constraint: '>= 0.0.0'
        )
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
