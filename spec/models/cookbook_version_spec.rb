require 'spec_helper'

describe CookbookVersion do
  context 'associations' do
    it { should belong_to(:cookbook) }
  end

  context 'validations' do
    it { should validate_presence_of(:license) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:readme) }
    it { should validate_uniqueness_of(:version).scoped_to(:cookbook_id) }
    it { should validate_length_of(:license).is_at_most(255) }

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

    it 'validates that the version number is semantically correct' do
      cookbook = create(:cookbook)
      cookbook_version = build(:cookbook_version, cookbook: cookbook, version: 'hahano')
      expect(cookbook_version).to_not be_valid
      expect(cookbook_version.errors[:version]).to_not be_empty
      cookbook_version.version = '8.7.6'
      expect(cookbook_version).to be_valid
      expect(cookbook_version.errors[:version]).to be_empty
    end

    it 'includes a descriptive error message when content type validation fails' do
      cookbook = create(:cookbook)
      cookbook_version = build(
        :cookbook_version,
        cookbook: cookbook,
        tarball: File.open('spec/support/cookbook_fixtures/not-a-tarball.txt')
      )

      expect(cookbook_version).to_not be_valid
      expect(cookbook_version.errors[:tarball].first).to eql('can not be text/plain.')
      expect(cookbook_version.errors.full_messages.first).to eql('Tarball content type can not be text/plain.')
    end
  end

  context 'attachments' do
    it { should have_attached_file(:tarball) }
  end

  context 'the tarball URL' do
    it 'contains the community site ID if it is present' do
      cookbook_version = create(:cookbook_version, legacy_id: 101)

      url = URI(cookbook_version.tarball.url)

      expect(url.path).
        to end_with('cookbook_versions/tarballs/101/original/redis-test-v1.tgz')
    end

    it 'contains the Supermarket ID if it is a Supermarket-only version' do
      cookbook_version = create(:cookbook_version, legacy_id: nil)

      url = URI(cookbook_version.tarball.url)
      id = cookbook_version.id

      expect(url.path).
        to end_with("cookbook_versions/tarballs/#{id}/original/redis-test-v1.tgz")
    end
  end

  context '#download_count' do
    it 'is the sum of web_download_count and api_download_count' do
      cookbook_version = CookbookVersion.new(
        web_download_count: 1,
        api_download_count: 10
      )

      expect(cookbook_version.download_count).to eql(11)
    end
  end
end
