require 'rails_helper'

describe LicenseWorker do
  let(:cookbook_name) { 'apt' }
  let(:lw) { LicenseWorker.new }

  before do
    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation").
      to_return(status: 200, body: '', headers: {})
  end

  context 'when the cookbook version has a license' do
    let(:licensed_version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }
    let(:cookbook_version) { JSON.parse(licensed_version_json_response)['version'] }

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
    let(:no_license_version_json_response) { File.read('spec/support/cookbook_version_no_license_fixture.json') }
    let(:cookbook_version) { JSON.parse(no_license_version_json_response)['version'] }

    before do
      stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation").
        to_return(status: 200, body: '', headers: {})
    end

    it 'indicates that the license metric failed' do
      lw.perform(no_license_version_json_response, cookbook_name)

      assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbook-versions/license_evaluation", times: 1) do |req|
         expect(req.body).to include("cookbook_name=#{cookbook_name}")
         expect(req.body).to include("cookbook_version=#{cookbook_version}")
         expect(req.body).to include('license_failure=true')
         expect(req.body).to include("license_feedback=#{cookbook_name}+has+no+license")
      end
    end
  end
end
