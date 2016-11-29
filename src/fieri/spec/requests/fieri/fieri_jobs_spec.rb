require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  describe 'POST /fieri_jobs' do
    context 'a valid job is posted' do
      let(:valid_params) do
        { cookbook_name: 'redis',
          cookbook_version: '1.2.0',
          cookbook_artifact_url: 'http://example.com/apache.tar.gz' }
      end

      before do
        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis/versions/1.2.0').
          to_return(status: 200, body: '', headers: {})
      end

      it 'should return a 200' do
        post fieri.jobs_path valid_params
        expect(response).to have_http_status(200)
      end

      describe 'the worker is a FoodcriticWorker' do
        it 'should queue a Foodcritic worker' do
          expect { post fieri.jobs_path valid_params }
            .to change { FoodcriticWorker.jobs.size }
            .by(1)
        end
      end

      describe 'the worker is a CollaboratorWorker' do
        it 'should queue a CollaboratorWorker' do
          expect { post fieri.jobs_path valid_params }
            .to change { CollaboratorWorker.jobs.size }
            .by(1)
        end
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
