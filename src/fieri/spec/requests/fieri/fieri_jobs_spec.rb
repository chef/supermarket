require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  describe 'POST /fieri_jobs' do
    let(:valid_params) do
      { fieri_key: ENV['FIERI_KEY'],
        cookbook: {
          name: 'redis',
          version: '1.2.0',
          artifact_url: 'http://example.com/apache.tar.gz'
        } }
    end

    context 'a valid job is posted' do
      before do
        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis').
          to_return(status: 200, body: '', headers: {})

        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis/versions/1.2.0').
          to_return(status: 200, body: '', headers: {})
      end

      it 'should return a 200' do
        post fieri.jobs_path valid_params
        expect(response).to have_http_status(200)
      end

      describe 'the MetricsRunner worker' do
        it 'queues a MetricsRunner worker' do
          expect { post fieri.jobs_path valid_params }
            .to change { MetricsRunner.jobs.size }
            .by(1)
        end
      end
    end

    describe 'when an invalid job is posted' do
      before do
        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis').
          to_return(status: 200, body: '', headers: {})

        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis/versions/').
          to_return(status: 200, body: '', headers: {})

        stub_request(:get, 'http://localhost:13000/api/v1/cookbooks/redis/versions/1.2.0').
          to_return(status: 200, body: '', headers: {})
      end

      it 'should return a 400' do
        post fieri.jobs_path(valid_params.merge(cookbook: { name: 'without_other_req_params' }))
        expect(response).to have_http_status(400)
      end
    end
  end
end
