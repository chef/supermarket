require 'rails_helper'

module Fieri
  RSpec.describe JobsController, type: :controller do
    routes { Fieri::Engine.routes }

    describe '#create' do
      let(:params) do
        {
          'fieri_key' => ENV['FIERI_KEY'],
          'cookbook' =>
          {
            'name' => 'apache2',
            'version' => '1.2.0',
            'artifact_url' => 'http://example.com/apache.tar.gz'
          }
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
        expect(MetricsRunner).to receive(:perform_async).with(hash_including(params['cookbook']))
        post :create, params: params
      end

      context 'authenticating submissions for cookbook evaluation' do
        it 'fails when the fieri_key is not present' do
          post :create, params: params.except('fieri_key')

          expect(response.status).to eq(400)
        end

        it 'fails when the fieri_key does not match' do
          expect(subject).to receive(:fieri_key).and_return('totally_not_the_fieri_key')

          post :create, params: params

          expect(response.status).to eq(401)
        end
      end
    end
  end
end
