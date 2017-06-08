require 'rails_helper'
require 'sidekiq/api'

RSpec.describe 'Jobs', type: :request do
  describe 'GET /status' do
    describe 'when a valid job is posted' do
      let(:valid_params) do
        { fieri_key: ENV['FIERI_KEY'],
          cookbook: {
            name: 'redis',
            version: '1.2.0',
            artifact_url: 'http://example.com/apache.tar.gz'
          } }
      end

      before do
        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis').
          to_return(status: 200, body: '', headers: {})

        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis/versions/1.2.0').
          to_return(status: 200, body: '', headers: {})
      end

      it 'should return a 200' do
        get fieri.status_path
        expect(response).to have_http_status(200)
      end

      it 'should return the status' do
        Sidekiq::Worker.clear_all
        Sidekiq::Queue.new.clear
        Sidekiq::Testing.disable! do
          post fieri.jobs_path valid_params
          get fieri.status_path

          expect(response.body).to match(/ok/)
          expect(response.body).to match(/\"queued_jobs\":1/)
        end
      end
    end
  end
end
