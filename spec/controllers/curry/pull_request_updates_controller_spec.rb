require 'spec_helper'

describe Curry::PullRequestUpdatesController do
  describe 'when GitHub sends a POST request' do

    before do
      allow(Curry::ImportUnknownPullRequestCommitAuthorsWorker).to receive(:perform_async)
      allow(OpenSSL::HMAC).to receive(:hexdigest) { 'csrf' }
    end

    let!(:repository) do
      create(:repository, owner: 'cramerdev', name: 'paprika')
    end

    def secure_post(action, params = {})
      request.env['HTTP_X_HUB_SIGNATURE'] = 'sha1=csrf'

      post action, params
    end

    context 'when the action is not "closed"' do

      let(:payload) do
        File.read('spec/support/request_fixtures/github_open_pull_request.json')
      end

      it 'creates a Pull Request Update' do
        expect do
          secure_post :create, payload: payload
        end.to change(Curry::PullRequestUpdate, :count).by(1)
      end

      it 'creates a Pull Request if a Pull Request record for that Pull Request does not exist' do
        expect do
          secure_post :create, payload: payload
        end.to change(Curry::PullRequest, :count).by(1)
      end

      it 'does not create a Pull Request if a Pull Request record for that Pull Request exists' do
        Curry::PullRequest.create(
          number: JSON.parse(payload).fetch('number'),
          repository: repository
        )

        expect do
          secure_post :create, payload: payload
        end.to change(Curry::PullRequest, :count).by(0)
      end

      it 'returns a 200' do
        secure_post :create, payload: payload

        expect(response.status.to_i).to eql(200)
      end

      it "starts a background job to validate the Pull Request commit authors' CLA status" do
        expect(Curry::ImportUnknownPullRequestCommitAuthorsWorker).
          to receive(:perform_async)

        secure_post :create, payload: payload
      end

    end

    context 'when the action is "closed"' do

      let(:payload) do
        File.read('spec/support/request_fixtures/github_close_pull_request.json')
      end

      it 'creates a Pull Request Update' do
        expect do
          secure_post :create, payload: payload
        end.to change(Curry::PullRequestUpdate, :count).by(1)
      end

      it 'returns a 200' do
        secure_post :create, payload: payload

        expect(response.status.to_i).to eql(200)
      end

      it "does not start a background job to validate the PR commit authors' CLA status" do
        expect(Curry::ImportUnknownPullRequestCommitAuthorsWorker).
          to_not receive(:perform_async)

        secure_post :create, payload: payload
      end

    end
  end
end
