require 'spec_helper'

describe CookbookUpload::Parameters do
  include TarballHelpers

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

    it 'is extracted from the top-level metadata.json' do
      tarball = build_cookbook_tarball('multiple-metadata') do |base|
        base.file('metadata.json') do
          JSON.dump(name: 'multiple')
        end
        base.file('PaxHeader/metadata.json') do
          JSON.dump(name: 'PaxHeader-multiple')
        end
      end

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.metadata.name).to eql('multiple')
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

    it 'is extracted from the top-level README' do
      tarball = build_cookbook_tarball('multiple-readme') do |base|
        base.file('metadata.json') { JSON.dump(name: 'multiple-readme') }
        base.file('README') { 'readme' }
        base.file('PaxHeader/metadata.json') do
          JSON.dump(name: 'multiple-readme')
        end
        base.file('PaxHeader/README') { 'impostor readme' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.readme.contents).to eql('readme')
    end

    it 'is blank if the tarball parameter is not a file' do
      params = params(cookbook: '{}', tarball: 'tarball!')

      expect(params.readme).to eql(CookbookUpload::Document.new)
    end

    it 'is blank if the tarball parameter is not GZipped' do
      file = Tempfile.open('notgzipped') { |f| f << 'metadata' }

      params = params(cookbook: '{}', tarball: file)

      expect(params.readme).to eql(CookbookUpload::Document.new)
    end

    it 'is blank if the tarball parameter has no README entry' do
      tarball = File.open('spec/support/cookbook_fixtures/no-metadata-or-readme.tgz')

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.readme).to eql(CookbookUpload::Document.new)
    end

    it 'can have an extension' do
      tarball = build_cookbook_tarball do |base|
        base.file('README.markdown') { '# README' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      readme = CookbookUpload::Document.new(
        contents: '# README',
        extension: 'markdown'
      )

      expect(params.readme).to eql(readme)
    end

    it 'has a blank extension if the README has none' do
      tarball = build_cookbook_tarball do |base|
        base.file('README') { 'README' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      readme = CookbookUpload::Document.new(
        contents: 'README',
        extension: ''
      )

      expect(params.readme).to eql(readme)
    end
  end

  describe '#changelog' do
    it 'is extracted from the tarball' do
      tarball = build_cookbook_tarball do |base|
        base.file('CHANGELOG.md') { 'ch-ch-changes' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.changelog.contents).to eql('ch-ch-changes')
      expect(params.changelog.extension).to eql('md')
    end

    it 'is extracted from the top-level CHANGELOG' do
      tarball = build_cookbook_tarball do |base|
        base.file('CHANGELOG.md') { 'ch-ch-changes' }
        base.file('PaxHeader/CHANGELOG.md') { 'not these changes' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.changelog.contents).to eql('ch-ch-changes')
    end

    it 'is blank if the tarball parameter is not a file' do
      params = params(cookbook: '{}', tarball: 'tarball')

      expect(params.changelog).to eql(CookbookUpload::Document.new)
    end

    it 'is blank if the tarball parameter is not GZipped' do
      file = Tempfile.open('notgzipped') { |f| f << 'metadata' }

      params = params(cookbook: '{}', tarball: file)

      expect(params.changelog).to eql(CookbookUpload::Document.new)
    end

    it 'is blank if the tarball parameter has no CHANGELOG entry' do
      tarball = build_cookbook_tarball do |base|
        base.file('README.md') { '# README' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      expect(params.changelog).to eql(CookbookUpload::Document.new)
    end

    it 'can have an extension' do
      tarball = build_cookbook_tarball do |base|
        base.file('CHANGELOG.markdown') { '# Markdown' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      changelog = CookbookUpload::Document.new(
        contents: '# Markdown',
        extension: 'markdown'
      )

      expect(params.changelog).to eql(changelog)
    end

    it 'has a blank extension if the CHANGELOG has none' do
      tarball = build_cookbook_tarball do |base|
        base.file('CHANGELOG') { 'Plain text' }
      end

      params = params(cookbook: '{}', tarball: tarball)

      changelog = CookbookUpload::Document.new(
        contents: 'Plain text',
        extension: ''
      )

      expect(params.changelog).to eql(changelog)
    end
  end
end
