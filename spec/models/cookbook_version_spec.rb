require 'spec_helper'

describe CookbookVersion do
  context 'associations' do
    it { should belong_to(:cookbook) }
  end

  context 'validations' do
    it { should validate_presence_of(:license) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:cookbook) }
    it { should validate_uniqueness_of(:version).scoped_to(:cookbook_id) }

    it 'seriously validates the uniqueness of cookbook version numbers' do
      cookbook = create(:cookbook)
      cookbook_version = create(:cookbook_version, cookbook: cookbook)

      duplicate_version = CookbookVersion.new(
        cookbook: cookbook,
        license: cookbook_version.license,
        tarball: cookbook_version.tarball,
        version: cookbook_version.version
      )

      expect do
        duplicate_version.save(validate: false)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context 'attachments' do
    it { should have_attached_file(:tarball) }
  end

  context '#to_param' do
    it 'returns the version in underscore format' do
      cookbook_version = CookbookVersion.new(version: '1.1.0')

      expect(cookbook_version.to_param).to eql('1_1_0')
    end
  end
end
