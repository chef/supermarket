require 'spec_helper'
require 'vcr_helper'

describe Curry::RepositorySubscriber do
  let!(:client) { Octokit::Client.new access_token: ENV['GITHUB_ACCESS_TOKEN'] }
  let!(:test_callback_url) { 'http://localhost:3000/curry/pull_request_updates' }
  let!(:previous_url) { 'https://example.com/previous_callback_url' }
  let!(:current_url)  { 'https://example.com/current_callback_url' }
  let!(:override_url) { 'https://example.com/overridden_callback_url' }

  describe '#subscribe!' do
    around(:each) do |example|
      VCR.use_cassette('curry_repository_subscriber', record: :once) do
        example.run
      end
    end

    context 'for a repository that exists' do
      let!(:subscriber) do
        Curry::RepositorySubscriber.new(
          Curry::Repository.new(owner: 'chef', name: 'paprika')
        )
      end

      it "returns true when able to subscribe to the repository's hub" do
        expect(subscriber.subscribe!).to be true
      end

      it 'adds a webhook to the repository for the callback_url' do
        subscriber.subscribe!
        repository_hook_urls = client.hooks(subscriber.repository.full_name).map do |hook|
          hook[:config][:url]
        end
        expect(repository_hook_urls)
          .to include(test_callback_url)
      end

      it 'saves a repository record in the act of subscribing' do
        expect { subscriber.subscribe! }
          .to change(Curry::Repository, :count)
          .by(1)
      end

      it 'saves the callback url with the repository' do
        subscriber = Curry::RepositorySubscriber.new(
          build(:repository)
        )

        expect { subscriber.subscribe! }
          .to change { subscriber.repository.callback_url }
          .to eql(test_callback_url)
      end
    end

    context 'for a repository that does not exist' do
      let!(:subscriber) do
        Curry::RepositorySubscriber.new(
          build(:repository, name: 'not_paprika')
        )
      end

      it "returns false when unable to subscribe to the repository's hub" do
        expect(subscriber.subscribe!).to be false
      end

      it 'does not save repositories to which it cannot subscribe' do
        expect { subscriber.subscribe! }
          .to_not change(Curry::Repository, :count)
      end

      it 'records errors which occur while subscribing' do
        subscriber.subscribe!

        expect(subscriber.repository.errors).to_not be_nil
      end
    end

    context 'when the environment has a PubSubHubbub callback url set' do
      it 'subscribes using the overridden callback URL from the environment' do
        ENV['PUBSUBHUBBUB_CALLBACK_URL'] = override_url

        subscriber = Curry::RepositorySubscriber.new(
          build(:repository)
        )

        expect { subscriber.subscribe! }
          .to change { subscriber.repository.callback_url }
          .to eql(override_url)

        ENV.delete('PUBSUBHUBBUB_CALLBACK_URL')
      end
    end
  end

  describe '#unsubscribe!' do
    around(:each) do |example|
      VCR.use_cassette('curry_repository_unsubscriber', record: :once) do
        example.run
      end
    end

    let!(:subscriber) do
      Curry::RepositorySubscriber.new(
        create(:repository)
      )
    end

    it "returns true when able to unsubscribe to the repository's hub" do
      subscriber.subscribe!

      expect(subscriber.unsubscribe!).to be_truthy
    end

    it 'unsubscribes the PubSubHubbub hook' do
      subscriber.subscribe!

      expect { subscriber.unsubscribe! }
        .to change { client.hooks('chef/paprika').size }
        .by(-1)
    end

    it "it destroys the RepositorySubscriber's repository record" do
      subscriber.subscribe!

      expect { subscriber.unsubscribe! }
        .to change(Curry::Repository, :count)
        .by(-1)
    end

    it 'still destroys the repository if the hook is already gone' do
      subscriber.subscribe!
      client.unsubscribe(subscriber.send(:topic), subscriber.repository.callback_url)

      expect { subscriber.unsubscribe! }
        .to change(Curry::Repository, :count)
        .by(-1)
    end
  end

  describe '#resubscribe!' do
    around(:each) do |example|
      VCR.use_cassette('curry_repository_resubscriber', record: :once) do
        ENV['PUBSUBHUBBUB_CALLBACK_URL'] = previous_url
        subscriber.subscribe!
        ENV['PUBSUBHUBBUB_CALLBACK_URL'] = current_url

        example.run

        ENV.delete('PUBSUBHUBBUB_CALLBACK_URL')
      end
    end

    let!(:repository)   { create(:repository) }
    let!(:subscriber)   { Curry::RepositorySubscriber.new repository }

    it 'sets the callback_url to the current url' do
      expect { subscriber.resubscribe! }
        .to change { repository.callback_url }
        .to eql(current_url)
    end

    it 'does not change the number of curried repositories' do
      expect { subscriber.resubscribe! }
        .to_not change(Curry::Repository, :count)
    end

    it 'adds a webhook to the repository for the current callback_url' do
      subscriber.resubscribe!
      repository_hook_urls = client.hooks(subscriber.repository.full_name).map do |hook|
        hook[:config][:url]
      end

      expect(repository_hook_urls)
        .to include(current_url)
    end

    it 'removes the webhook from the repository for the previous callback_url' do
      subscriber.resubscribe!
      repository_hook_urls = client.hooks(subscriber.repository.full_name).map do |hook|
        hook[:config][:url]
      end

      expect(repository_hook_urls)
        .to_not include(previous_url)
    end
  end
end
