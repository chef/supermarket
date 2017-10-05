require 'rails_helper'

describe SupermarketApiRunner do
  let(:supermarket_runner) { SupermarketApiRunner.new }
  let(:cookbook_name) { 'super_cookbook' }
  let(:cookbook_version) { '1.2' }

  let(:cookbook_uri) { "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{cookbook_name}" }
  let(:cookbook_json_response) { File.read('spec/support/cookbook_metrics_fixture.json') }

  let(:version_uri) { "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{cookbook_name}/versions/#{cookbook_version}" }
  let(:version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }

  before do
    stub_request(:get, cookbook_uri).
      to_return(status: 200, body: cookbook_json_response, headers: {})

    stub_request(:get, version_uri).
      to_return(status: 200, body: version_json_response, headers: {})
  end

  describe '#cookbook_api_response' do
    it 'calls the supermarket api' do
      expect(Net::HTTP).to receive(:get).once.with(URI.parse(cookbook_uri)).and_return(cookbook_json_response)
      supermarket_runner.cookbook_api_response(cookbook_name)
    end
  end

  describe '#cookbook_version_api_response' do
    it 'calls the supermarket api' do
      expect(Net::HTTP).to receive(:get).once.with(URI.parse(version_uri)).and_return(version_json_response)
      supermarket_runner.cookbook_version_api_response(cookbook_name, cookbook_version)
    end
  end
end
