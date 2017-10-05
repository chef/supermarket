require 'rails_helper'

describe CollaboratorWorker do
  let(:pw) { PublishWorker.new }
  let(:cookbook_name) { 'apache2' }
  let(:cookbook_response) { File.read('spec/support/cookbook_metrics_fixture.json') }
  let(:uri) { "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{cookbook_name}" }

  before do
    stub_request(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation").
      to_return(status: 200, body: '', headers: {})
  end

  it 'parses the response as json' do
    expect(JSON).to receive(:parse).with(cookbook_response).and_return(cookbook_response)
    pw.perform(cookbook_response, cookbook_name)
  end

  context 'checking whether the cookbook exists on supermarket' do
    context 'when it exists' do
      it 'indicates that the publish metric passed' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_failure=false')
        end
      end
    end

    context 'when it does not exist' do
      let(:cookbook_does_not_exist_json_response) { File.read('spec/support/cookbook_does_not_exist.json') }

      it 'indicates that the publish metric failed' do
        pw.perform(cookbook_does_not_exist_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_failure=true')
        end
      end

      it 'includes a message in the feedback' do
        pw.perform(cookbook_does_not_exist_json_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_feedback')
          expect(req.body).to include("#{cookbook_name}+not+found+in+Supermarket")
        end
      end
    end
  end

  context 'checking whether the cookbook is deprecated' do
    context 'when the cookbook is deprecated' do
      let(:cookbook_response) { File.read('spec/support/cookbook_deprecated_fixture.json') }

      it 'indicates the publish metric failed' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_failure=true')
        end
      end

      it 'includes a message in the feedback' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_feedback')
          expect(req.body).to include("#{cookbook_name}+is+deprecated")
        end
      end
    end

    context 'when the cookbook is not deprecated' do
      let(:cookbook_response) { File.read('spec/support/cookbook_non_deprecated_fixture.json') }

      it 'indicates the publish metric passed' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_failure=false')
        end
      end
    end
  end

  context 'checking whether the cookbook is up for adoption' do
    context 'when the cookbook is up for adoption' do
      let(:cookbook_response) { File.read('spec/support/cookbook_up_for_adoption_fixture.json') }

      it 'indicates the publish metric failed' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_failure=true')
        end
      end

      it 'includes a message in the feedback' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_feedback')
          expect(req.body).to include("#{cookbook_name}+is+up+for+adoption")
        end
      end
    end

    context 'when the cookbook is not up for adoption' do
      let(:cookbook_response) { File.read('spec/support/cookbook_not_up_for_adoption_fixture.json') }

      it 'indicates the publish metric passed' do
        pw.perform(cookbook_response, cookbook_name)

        assert_requested(:post, "#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/publish_evaluation", times: 1) do |req|
          expect(req.body).to include('publish_failure=false')
        end
      end
    end
  end
end
