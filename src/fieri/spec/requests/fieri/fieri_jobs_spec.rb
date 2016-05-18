require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  describe 'POST /fieri_jobs' do
    describe 'when a valid job is posted' do
      let(:valid_params) do
        { cookbook_name: 'redis',
          cookbook_version: '1.2.0',
          cookbook_artifact_url: 'http://example.com/apache.tar.gz' }
      end
      it 'should return a 200' do
        post fieri.jobs_path valid_params
        expect(response).to have_http_status(200)
      end

      it 'should queue a cookbook worker' do
        expect { post fieri.jobs_path valid_params }
          .to change { CookbookWorker.jobs.size }
          .by(1)
      end
    end

    describe 'when an invalid job is posted' do
      it 'should return a 400' do
        post fieri.jobs_path(cookbook_name: 'redis')
        expect(response).to have_http_status(400)
      end
    end
  end
end
