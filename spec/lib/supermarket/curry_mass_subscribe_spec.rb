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

      it 'finds all public repos for the organization' do
        expect(client).to receive(:org_repos).with(sample_org, private: true).and_return([])
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

      it 'iterates over the public repos' do
        expect(sample_org_public_repos).to receive(:each)
        curry_mass_subscribe.subscribe_org_repos(sample_org)
      end

      it 'checks whether the repo is already monitored by Curry' do
        allow(client).to receive(:org_repos).and_return([sample_org_public_repos.first])
        expect(Curry::Repository).to receive(:where)
        .with(owner: sample_org, name: sample_org_public_repos.first[:name])

        curry_mass_subscribe.subscribe_org_repos(sample_org)
      end

      context 'when the repository is not already monitored by Curry' do
        let(:curry_repository) do
          Curry::Repository.new(owner: sample_org, name: 'Some Name', callback_url: 'http://example.com')
        end

        let(:repository_subscriber) { Curry::RepositorySubscriber.new(curry_repository) }

        before do
          allow(Curry::Repository).to receive(:where).and_return([])
          allow(Curry::Repository).to receive(:new).and_return(curry_repository)
          allow(client).to receive(:org_repos).and_return([sample_org_public_repos.first])
          allow(Curry::RepositorySubscriber).to receive(:new).and_return(repository_subscriber)
        end

        it 'creates a new repository record' do
          expect(Curry::Repository).to receive(:new).with(owner: sample_org, name: sample_org_public_repos.first[:name])

          curry_mass_subscribe.subscribe_org_repos(sample_org)
        end

        it 'creates a new repository subscriber object' do
          expect(Curry::RepositorySubscriber).to receive(:new).with(curry_repository)
          curry_mass_subscribe.subscribe_org_repos(sample_org)
        end

        it 'subscribes the repository' do
          allow(Curry::RepositorySubscriber).to receive(:new).and_return(repository_subscriber)
          expect(repository_subscriber).to receive(:subscribe)
          curry_mass_subscribe.subscribe_org_repos(sample_org)
        end

        it 'includes the curry_pull_request_updates_url' do
          expect(repository_subscriber).to receive(:subscribe).with('https://supermarket.chef.io/curry/pull_request_updates')
          curry_mass_subscribe.subscribe_org_repos(sample_org)
        end

        context 'when the subscribe is successful' do
          before do
            allow(Curry::RepositorySubscriber).to receive(:new).and_return(repository_subscriber)
            allow(repository_subscriber).to receive(:subscribe).and_return(true)
          end

          it 'creates a subscription worker' do
            # Save the curry worker so we can get the id
            curry_repository.save!

            expect(Curry::RepositorySubscriptionWorker).to receive(:perform_async).with(curry_repository.id)
            curry_mass_subscribe.subscribe_org_repos(sample_org)
          end

        end

        context 'when the subscribe is not successful' do
          before do
            allow(Curry::RepositorySubscriber).to receive(:new).and_return(repository_subscriber)
            allow(repository_subscriber).to receive(:subscribe).and_return(false)
          end

          it 'does not create a subscription worker' do
            expect(Curry::RepositorySubscriptionWorker).to_not receive(:perform_async)
            curry_mass_subscribe.subscribe_org_repos(sample_org)
          end

          it 'displays a message' do
            expect { curry_mass_subscribe.subscribe_org_repos(sample_org) }.to output("Unable to subscribe #{curry_repository.name}\n").to_stdout
          end
        end
      end

      context 'when the repository is already monitored by Curry' do
        let!(:existing_repository) do
          Curry::Repository.create!(owner: sample_org, name: sample_org_public_repos.first[:name], callback_url: 'https://example.com')
        end

        before do
          allow(client).to receive(:org_repos).and_return([sample_org_public_repos.first])
          allow(Curry::Repository).to receive(:where).and_return([existing_repository])
        end

        it 'does not create a new repository' do
          expect(Curry::Repository).to_not receive(:new)
          curry_mass_subscribe.subscribe_org_repos(sample_org)
        end

        it 'displays a message' do
          expect { curry_mass_subscribe.subscribe_org_repos(sample_org) }.to output("#{sample_org_public_repos.first[:name]} is already subscribed.  Skipping...\n").to_stdout
        end
      end
    end
  end
end
