require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  describe 'GET /status' do
    describe 'when a valid job is posted' do
      let(:valid_params) do
        { cookbook_name: 'redis',
          cookbook_version: '1.2.0',
          cookbook_artifact_url: 'http://example.com/apache.tar.gz' }
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
