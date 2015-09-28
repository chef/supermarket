module Supermarket
  require 'octokit'

  class CurryMassSubscribe
    def subscribe_org_repos(org)
      public_repos(org).each do |repo|
        if Curry::Repository.where(owner: org, name: repo[:name]).present?
          puts "#{repo[:name]} is already subscribed.  Skipping..."
        else
          repository = Curry::Repository.new(owner: org, name: repo[:name])
          subscriber = Curry::RepositorySubscriber.new(repository)

          if subscriber.subscribe('https://supermarket.chef.io/curry/pull_request_updates')
            Curry::RepositorySubscriptionWorker.perform_async(repository.id)
          else
            puts "Unable to subscribe #{repository.name}"
          end
        end
      end
    end

    private

    def client
      Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end

    def public_repos(org)
      client.org_repos(org, private: true)
    end
  end
end
