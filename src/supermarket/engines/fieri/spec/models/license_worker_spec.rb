require 'rails_helper'

describe LicenseWorker do
  let(:cookbook_name) { 'apt' }
  let(:lw) { LicenseWorker.new }

  before do
    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation").
      to_return(status: 200, body: '', headers: {})
  end

  context 'when the cookbook version has a license' do
    let(:licensed_version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }
    let(:cookbook_version) { JSON.parse(licensed_version_json_response)['version'] }

    it 'indicates that the license metric passed' do
      lw.perform(licensed_version_json_response, cookbook_name)

      assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
        expect(req.body).to include("cookbook_name=#{cookbook_name}")
        expect(req.body).to include("cookbook_version=#{cookbook_version}")
        expect(req.body).to include('license_failure=false')
        expect(req.body).to_not include("license_feedback=#{cookbook_name}+needs+a+valid+open+source+license")
      end
    end
  end

  context 'when the cookbook version does not have a license' do
    let(:no_license_version_json_response) { File.read('spec/support/cookbook_version_no_license_fixture.json') }
    let(:cookbook_version) { JSON.parse(no_license_version_json_response)['version'] }

    it 'indicates that the license metric failed' do
      lw.perform(no_license_version_json_response, cookbook_name)

      assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
        expect(req.body).to include("cookbook_name=#{cookbook_name}")
        expect(req.body).to include("cookbook_version=#{cookbook_version}")
        expect(req.body).to include('license_failure=true')
        expect(req.body).to include("license_feedback=#{cookbook_name}+does+not+have+a+valid+open+source+license")
        expect(req.body).to include('Acceptable+licenses+include')
      end
    end
  end

  context 'acceptable licenses' do
    context 'when the cookbook version has the Apache 2.0 license' do
      let(:apache_license_version_json_response) { File.read('spec/support/cookbook_version_apache_2_0_license.json') }
      let(:cookbook_version) { JSON.parse(apache_license_version_json_response)['version'] }

      it 'passes the metric' do
        lw.perform(apache_license_version_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
          expect(req.body).to include('license_failure=false')
        end
      end
    end

    context 'when the cookbook version has the MIT license' do
      let(:mit_license_version_json_response) { File.read('spec/support/cookbook_version_mit_license.json') }
      let(:cookbook_version) { JSON.parse(mit_license_version_json_response)['version'] }

      it 'passes the metric' do
        lw.perform(mit_license_version_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
          expect(req.body).to include('license_failure=false')
        end
      end
    end

    context 'when the cookbook version has the GNU Public License 2.0' do
      let(:gnu_2_0_license_version_json_response) { File.read('spec/support/cookbook_version_gnu_public_license_2_0.json') }
      let(:cookbook_version) { JSON.parse(gnu_2_0_license_version_json_response)['version'] }

      it 'passes the metric' do
        lw.perform(gnu_2_0_license_version_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
          expect(req.body).to include('license_failure=false')
        end
      end
    end

    context 'when the cookbook version has the GNU Public License 3.0' do
      let(:gnu_3_0_license_version_json_response) { File.read('spec/support/cookbook_version_gnu_public_license_3_0.json') }
      let(:cookbook_version) { JSON.parse(gnu_3_0_license_version_json_response)['version'] }

      it 'passes the metric' do
        lw.perform(gnu_3_0_license_version_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
          expect(req.body).to include('license_failure=false')
        end
      end
    end
  end

  context 'non-acceptable license' do
    context 'when the cookbook version has a non-acceptable license' do
      let(:all_rights_license_version_json_response) { File.read('spec/support/cookbook_version_all_rights_license.json') }
      let(:cookbook_version) { JSON.parse(all_rights_license_version_json_response)['version'] }

      it 'fails the metric' do
        lw.perform(all_rights_license_version_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/license_evaluation", times: 1) do |req|
          expect(req.body).to include('license_failure=true')
        end
      end
    end
  end
end
