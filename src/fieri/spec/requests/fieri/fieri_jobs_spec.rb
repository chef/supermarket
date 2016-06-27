require 'rails_helper'
require 'sidekiq/testing'

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

    describe 'when a job is redirected' do
      let(:artifact) { CookbookArtifact.new('http://example.com/apache.tar.gz', 'somejobid2') }
      let(:valid_params) do
        { cookbook_name: 'redis',
          cookbook_version: '1.2.0',
          cookbook_artifact_url: 'http://example.com/apache.tar.gz' }
      end

      before do
        stub_request(:get, 'http://example.com/apache.tar.gz').
          to_return(
            body: File.open(File.expand_path('./spec/fixtures/apache-no-metadata.rb.tar.gz')),
            status: 200
        )
        allow_any_instance_of(CookbookArtifact).to receive(:criticize).and_return(['FC023: Prefer conditional attributes: /var/folders/m3/r80gybns1v357ff8q40pxw980000gn/T/e8f370c280fb21201b8d491d/apache2/definitions/apache_conf.rb:38', true])
      end

      it 'should be rescued' do
        ENV['FIERI_LOG_PATH'] = './spec/fixtures/fieri_test_log.log'
        logger = double('logger')
        allow(Logger).to receive(:new).and_return(logger)

        allow(logger).to receive(:level=) { 1 }
        allow(logger).to receive(:formatter=) { Sidekiq::Logging::Pretty }
        allow(logger).to receive(:debug) { "Sidekiq client with redis options {:url=>nil}"}
        Sidekiq::Testing.inline! do
          allow(Net::HTTP).to receive(:post_form).and_raise("errors")
          expect(logger).to receive(:error)
          CookbookWorker.perform_async(valid_params)
        end
      end
    end
  end
end
