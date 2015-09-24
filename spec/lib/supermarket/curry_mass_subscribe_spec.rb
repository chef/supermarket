require 'spec_helper'
require 'vcr_helper'

describe Supermarket::CurryMassSubscribe do
  describe '#subscribe_org_repos' do
    let(:curry_mass_subscribe) { Supermarket::CurryMassSubscribe.new }
    let(:sample_org) { 'chef-cookbooks' }

    let!(:client) do
      #  Should you need to re-record this cassette, obtain a valid Github Access Token
      #  Then Uncomment this variable and assign your valid token to the env variable
      #  ENV['GIHUB_ACCESS_TOKEN'] = Valid Github Access Token
      #  Then change 'record: :once' to 'record :all' and run the specs
      #  After everything passes, delete you token from the env variable declaration above
      #  and recomment the ENV['GITHUB_ACCESS_TOKEN'] line

      VCR.use_cassette('github_api_client', record: :once) do
        require 'octokit'

        Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
      end
    end

    context 'connecting to the Github API' do
      before do
        allow(Octokit::Client).to receive(:new).and_return(client)
      end

      it 'initiates a connection to the Github API' do
        expect(Octokit::Client).to receive(:new).with(access_token: ENV['GITHUB_ACCESS_TOKEN'])
        curry_mass_subscribe.subscribe_org_repos(sample_org)
      end

      it 'finds all public repos for the organization' do
        expect(client).to receive(:org_repos).with(sample_org)
        curry_mass_subscribe.subscribe_org_repos(sample_org)
      end
    end

    context 'processing the public repos' do
      let(:sample_org_public_repos) do
        #  Should you need to re-record this cassette, obtain a valid Github Access Token
        #  Then Uncomment this variable and assign your valid token to the env variable
        #  ENV['GIHUB_ACCESS_TOKEN'] = Valid Github Access Token
        #  Then change 'record: :once' to 'record :all' and run the specs
        #  After everything passes, delete you token from the env variable declaration above
        #  and recomment the ENV['GITHUB_ACCESS_TOKEN'] line

        VCR.use_cassette('github_org_public_repos', record: :once) do
          require 'octokit'

          Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN']).org_repos('chef-cookbooks')
        end
      end

      before do
        allow(Octokit::Client).to receive(:new).and_return(client)
        allow(client).to receive(:org_repos).and_return(sample_org_public_repos)
      end

      it 'checks whether the repo is already monitored by Curry' do

      end

      context 'when the repository is not already monitored by Curry' do

      end


      context 'when the repository is already monitored by Curry' do

      end
    end
  end
end
