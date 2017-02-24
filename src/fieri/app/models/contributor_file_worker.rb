require 'sidekiq'
require 'net/http'
require 'octokit'

class ContributorFileWorker
  include ::Sidekiq::Worker

  def perform(cookbook_json)
    evaluate_result = evaluate(cookbook_json)

    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/contributor_file_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name(cookbook_json),
      contributor_file_failure: evaluate_result,
      contributor_file_feedback: give_feedback(evaluate_result)
    )
  end

  private

  def cookbook_name(cookbook_json)
    JSON.parse(cookbook_json)['name']
  end

  def source_user_repo(cookbook_json)
    # http://rubular.com/r/wHJrs02iLs
    cookbook_json.match(%r{(?<=github.com\/)[\w-]+\/[\w-]+}).to_s
  end

  def evaluate(cookbook_json)
    repo = source_user_repo(cookbook_json)

    if repo.empty?
      # if no match for repo from #source_user_repo, fails metric
      return true
    end

    begin
      octokit_client.contents(repo, path: 'CONTRIBUTING.md')
      # if found, does not fail the metric
      false
    rescue Octokit::NotFound
      # if not found, does fail the metric
      true
    end
  end

  def give_feedback(failure_result)
    if failure_result
      I18n.t(
        'quality_metrics.contributor_file.failure'
      )
    else
      I18n.t(
        'quality_metrics.contributor_file.success'
      )
    end
  end

  def octokit_client
    Octokit::Client.new(
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    )
  end
end
