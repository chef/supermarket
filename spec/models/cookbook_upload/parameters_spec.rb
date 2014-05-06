require 'isolated_spec_helper'
require 'cookbook_upload/parameters'

describe CookbookUpload::Parameters do

  def params(hash)
    CookbookUpload::Parameters.new(hash)
  end

  describe '#category_name' do
    it 'is extracted from the cookbook JSON' do
      params = params(cookbook: '{"category":"Cool"}', tarball: double)

      expect(params.category_name).to eql('Cool')
    end

    it 'is blank if the cookbook JSON is invalid' do
      params = params(cookbook: 'ack!', tarball: double)

      expect(params.category_name).to eql('')
    end
  end

  describe '#metadata' do
    it 'is extracted from the tarball' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      redis_metadata = CookbookUpload::Metadata.new(
        name: 'redis-test',
        version: '0.1.0',
        license: 'All rights reserved',
        description: 'Installs/Configures redis-test'
      )

      expect(params.metadata).to eql(redis_metadata)
    end

    it 'is blank if the tarball parameter is not a file' do
      params = params(cookbook: '{}', tarball: 'tarball!')

      expect(params.metadata).to eql(CookbookUpload::Metadata.new)
    end

    it 'is blank if the tarball parameter is not GZipped' do
      file = Tempfile.open('notgzipped') { |f| f << 'metadata' }

      params = params(cookbook: '{}', tarball: file)

      expect(params.metadata).to eql(CookbookUpload::Metadata.new)
    end

    it 'is blank if the tarball parameter has no metadata.json entry' do
      tarball = File.open('spec/support/cookbook_fixtures/no-metadata-or-readme.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.metadata).to eql(CookbookUpload::Metadata.new)
    end

    it "is blank if the tarball's metadata.json entry is not actually JSON" do
      tarball = File.open('spec/support/cookbook_fixtures/invalid-metadata-json.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.metadata).to eql(CookbookUpload::Metadata.new)
    end
  end

  describe '#readme' do
    it 'is extracted from the tarball' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.readme.contents).to_not be_empty
      expect(params.readme.extension).to eql('md')
    end

    it 'is blank if the tarball parameter is not a file' do
      params = params(cookbook: '{}', tarball: 'tarball!')

      expect(params.readme).to eql(CookbookUpload::Readme.new)
    end

    it 'is blank if the tarball parameter is not GZipped' do
      file = Tempfile.open('notgzipped') { |f| f << 'metadata' }

      params = params(cookbook: '{}', tarball: file)

      expect(params.readme).to eql(CookbookUpload::Readme.new)
    end

    it 'is blank if the tarball parameter has no README entry' do
      tarball = File.open('spec/support/cookbook_fixtures/no-metadata-or-readme.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.readme).to eql(CookbookUpload::Readme.new)
    end
  end
end
