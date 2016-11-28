require 'rails_helper'

describe LicenseWorker do
  context 'when the cookbook version has a license' do
    let(:licensed_version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }
    let(:cookbook_name) { 'apt' }
    let(:cookbook_version) { JSON.parse(licensed_version_json_response)['version'] }
    let(:lw) { LicenseWorker.new }

    before do
      stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation").
        to_return(status: 200, body: '', headers: {})
    end

    it 'indicates that the license metric passed' do
      lw.perform(licensed_version_json_response, cookbook_name)

      assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation", times: 1) do |req|
         expect(req.body).to include("cookbook_name=#{cookbook_name}")
         expect(req.body).to include("cookbook_version=#{cookbook_version}")
         expect(req.body).to include('license_failure=false')
         expect(req.body).to include('license_feedback=')
      end
    end
  end

  context 'when the cookbook version does not have a license' do
    it 'indicates that the license metric failed'
    it 'includes a message in the feedback'
  end
end
