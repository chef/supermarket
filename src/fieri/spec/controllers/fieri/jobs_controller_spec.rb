require 'rails_helper'

module Fieri
  RSpec.describe JobsController, type: :controller do
    routes { Fieri::Engine.routes }

    describe '#create' do
      let(:params) do
        {
          'cookbook_artifact_url' => 'http://example.com/apache.tar.gz',
          'cookbook_name' => 'apache2',
          'cookbook_version' => '1.2.0'
        }
      end

      let(:supermarket_api_runner) { SupermarketApiRunner.new }
      let(:cookbook_json_response) { File.read('spec/support/cookbook_metrics_fixture.json') }
      let(:version_json_response) { File.read('spec/support/cookbook_version_fixture.json') }

      before do
        allow(SupermarketApiRunner).to receive(:new).and_return(supermarket_api_runner)
        allow(supermarket_api_runner).to receive(:cookbook_api_response).and_return(cookbook_json_response)
        allow(supermarket_api_runner).to receive(:cookbook_version_api_response).and_return(version_json_response)
      end

      it 'calls the MetricsRunner' do
        expect(MetricsRunner).to receive(:perform_async).with(hash_including(params))
        post :create, params: params
      end
    end
  end
end
