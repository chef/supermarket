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

      stub_request(:post, ENV['FIERI_URL']).
       to_return(:status => 200, :body => "", :headers => {})
    end

    it 'includes the correct cookbook artifact url' do
      expect(version).to receive(:cookbook_artifact_url)

      worker = FieriNotifyWorker.new
      worker.perform(version.id)
    end
  end
end
