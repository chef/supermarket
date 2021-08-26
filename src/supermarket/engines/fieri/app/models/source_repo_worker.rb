require "sidekiq"
require "net/http"
require "octokit"

class SourceRepoWorker
  private

  def source_repo(cookbook_json)
    url = source_repo_url(cookbook_json)
   # https://rubular.com/r/uTLH7q6rJES5xW
    url.match(%r{^(https?\://)?(github\.com/)(\w+/\w+)}).try(:[], 3).to_s
  end

  def source_repo_url(cookbook_json)
    JSON.parse(cookbook_json).fetch("source_url", "") || ""
  end

  def octokit_client
    Octokit::Client.new(
      access_token: ENV["GITHUB_ACCESS_TOKEN"]
    )
  end
end
