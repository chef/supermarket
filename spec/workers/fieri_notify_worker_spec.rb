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
end
