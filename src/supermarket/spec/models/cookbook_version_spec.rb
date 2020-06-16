require 'spec_helper'
require 'webmock/rspec'

describe CookbookVersion do
  context 'associations' do
    it { should belong_to(:cookbook) }
    it { should have_many(:metric_results) }
  end

  context 'validations' do
    it { should validate_presence_of(:license) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:readme) }
    it { should validate_length_of(:license).is_at_most(255) }

    context 'for version number' do
      let(:cookbook) { create(:cookbook) }
      let(:cookbook_version) { create(:cookbook_version, cookbook: cookbook) }

      it 'passes for a valid version number format x.y.z' do
        cookbook_version.version = '1.2.3'
        expect(cookbook_version).to be_valid
        expect(cookbook_version.errors[:version]).to be_empty
      end

      it "validates uniqueness of version for a cookbook" do
        cookbook_version
        should validate_uniqueness_of(:version)
          .scoped_to(:cookbook_id)
          .case_insensitive
      end

      it 'seriously validates the uniqueness of cookbook version numbers' do
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

      context 'if not a valid chef version' do
        it 'fails on just a string of silliness' do
          cookbook_version.version = 'hahahano'
          expect(cookbook_version).to_not be_valid
          expect(cookbook_version.errors[:version]).to include(a_string_matching('not a valid Chef version'))
        end

        it 'fails on a dashed extra info like RC or pre' do
          cookbook_version.version = '1.2.3-RC1'
          expect(cookbook_version).to_not be_valid
          expect(cookbook_version.errors[:version]).to include(a_string_matching('not a valid Chef version'))
        end
      end
    end

    context 'when something that is not a tarball is given' do
      it 'includes an error that the content type is not supported' do
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

      it 'includes an error that the contents do not match the content type' do
        cookbook = create(:cookbook)
        cookbook_version = build(
          :cookbook_version,
          cookbook: cookbook,
          tarball: File.open('spec/support/cookbook_fixtures/not-a-tarball-and-lies-about-it.tgz')
        )

        expect(cookbook_version).to_not be_valid
        expect(cookbook_version.errors[:tarball].first).to eql('has contents that are not what they are reported to be')
        expect(cookbook_version.errors.full_messages.first).to eql('Tarball has contents that are not what they are reported to be')
      end

      it 'raises exception when a URL is given instead of tarball contents' do
        stub_request(:any, 'nope.example.com').to_raise("Attaching a URL should not make a network call.")
        cookbook = create(:cookbook)
        expect do
          build(:cookbook_version,
                cookbook: cookbook,
                tarball: 'http://nope.example.com/some/remote/file.tgz')
        end.to raise_error(Paperclip::AdapterRegistry::NoHandlerError)
      end

      it 'raises exception when Base64 content is given instead of tarball contents' do
        cookbook = create(:cookbook)
        naughty_tarball = build_cookbook_tarball('naughty') do |base|
          base.file('README.md') { '# This will be Base64 encoded' }
        end
        expect do
          build(:cookbook_version,
                cookbook: cookbook,
                tarball: "data:;base64,#{Base64.encode64(naughty_tarball.read)}")
        end.to raise_error(Paperclip::AdapterRegistry::NoHandlerError)
      end
    end
  end

  context '#published_by' do
    it 'returns the cookbook owner when a cookbook version user_id is nil' do
      cookbook = create(:cookbook)
      cookbook_version = build(
        :cookbook_version,
        cookbook: cookbook,
        user_id: nil
      )

      expect(cookbook_version.published_by).to eq(cookbook.owner)
    end

    it 'returns the cookbook version owner when a cookbook version user_id is present' do
      cookbook = create(:cookbook)
      cookbook_version = build(
        :cookbook_version,
        cookbook: cookbook
      )

      expect(cookbook_version.published_by).to eq(cookbook_version.user)
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

  context '#artifact_url' do
    let(:cookbook) { create(:cookbook) }
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    before do
      allow(CookbookVersion).to receive(:find).and_return(version)
    end

    context 'when using the filesystem for cookbook storage' do
      before do
        expect(Paperclip::Attachment.default_options[:storage]).to eq(:filesystem)
      end

      it 'includes the correct cookbook artifact url' do
        expect(version.cookbook_artifact_url).to eq("#{Supermarket::Host.full_url}#{version.tarball.url}")
      end
    end

    context 'when using S3 for cookbook storage' do
      before do
        allow(Paperclip::Attachment).to receive(:default_options).and_return(storage: 's3')

        # Paths for cookbooks are configured in config/initializers/paperclip.rb
        # These variables are set to simulate cookbooks which are configured to
        # be stored on S3
        default_s3_url = "https://s3.amazonaws.com/"
        s3_path = version.tarball.url.sub(%r{^/system}, '') # S3 cookbook paths do not have /system at the beginning of them

        s3_tarball_url = "#{default_s3_url}#{ENV['S3_BUCKET']}#{s3_path}"

        allow(version).to receive_message_chain(:tarball, :url).and_return(s3_tarball_url)
      end

      it 'includes the correct cookbook artifact url' do
        expect(version.cookbook_artifact_url).to include('https://s3.amazonaws.com')
        expect(version.cookbook_artifact_url).to eq(version.tarball.url.to_s)
      end

      context 'when the Supermarket is set to use expiring URLs' do
        before do
          ENV['S3_URLS_EXPIRE'] = '10'
        end

        it 'includes the expiration' do
          expect(version.tarball).to receive(:expiring_url)
            .with(ENV['S3_URLS_EXPIRE'].to_i)

          version.cookbook_artifact_url
        end
      end
    end
  end
end
