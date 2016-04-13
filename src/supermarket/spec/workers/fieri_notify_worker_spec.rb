require 'spec_helper'
require 'webmock/rspec'

describe FieriNotifyWorker do
  let(:cookbook) { create(:cookbook) }

  it 'sends a POST request to the configured fieri_url for cookbook evaluation' do
    stub_request(:any, ENV['FIERI_URL'])

    worker = FieriNotifyWorker.new
    result = worker.perform(cookbook.cookbook_versions.first.id)

    expect(result.class).to eql(Net::HTTPOK)
  end


  context 'setting the correct cookbook artifact url' do
    let(:version) { create(:cookbook_version, cookbook: cookbook) }

    before do
      allow(CookbookVersion).to receive(:find).and_return(version)
    end

    context 'when not using S3 for cookbook storage' do
      before do
        ENV['S3_BUCKET'] = nil
      end

      it 'includes the correct cookbook artifact url' do
        expect(Net::HTTP).to receive(:post_form).with(anything, hash_including("cookbook_artifact_url" => "#{Supermarket::Host.full_url}#{version.tarball.url}"))

        worker = FieriNotifyWorker.new
        worker.perform(version.id)
      end
    end

    context 'when using S3 for cookbook storage' do
      before do
        ENV['S3_BUCKET'] = 'mybucket'
        ENV['S3_ACCESS_KEY_ID'] = '123'
        ENV['S3_SECRET_ACCESS_KEY'] = '456'

        # Paths for cookbooks are configured in config/initializers/paperclip.rb
        # These variables are set to simulate cookbooks which are configured to
        # be stored on S3
        default_s3_url = "https://s3.amazonaws.com/"
        s3_path = version.tarball.url.sub(%r{^/system}, '') # S3 cookbook paths do not have /system at the beginning of them

        s3_tarball_url = "#{default_s3_url}#{ENV['S3_BUCKET']}#{s3_path}"

        allow(version).to receive_message_chain(:tarball, :url).and_return(s3_tarball_url)
      end

      it 'includes the correct cookbook artifact url' do
        expect(Net::HTTP).to receive(:post_form).with(anything, hash_including("cookbook_artifact_url" => version.tarball.url.to_s))
        worker = FieriNotifyWorker.new
        worker.perform(version.id)
      end
    end
  end
end
