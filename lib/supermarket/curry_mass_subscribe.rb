module Supermarket
  require 'Octokit'

  class CurryMassSubscribe

    def subscribe_org_repos(org)
      client.org_repos(org)
    end

    private

    def client
      Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    end
  end
end
