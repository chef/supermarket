require "sidekiq"
require "net/http"
require "octokit"

class ContributingFileWorker < SourceRepoWorker
  include ::Sidekiq::Worker

  def perform(cookbook_json, cookbook_name)
    evaluate_result = evaluate(cookbook_json)

    Net::HTTP.post_form(
      URI.parse("#{ENV["FIERI_SUPERMARKET_ENDPOINT"]}/api/v1/quality_metrics/contributing_file_evaluation"),
      fieri_key: ENV["FIERI_KEY"],
      cookbook_name: cookbook_name,
      contributing_file_failure: evaluate_result,
      contributing_file_feedback: give_feedback(evaluate_result)
    )
  end

  private

  def evaluate(cookbook_json)
    repo = source_repo(cookbook_json)

    # if no match for repo from #source_user_repo, fails metric
    return true if repo.blank?

    begin
      repo_contents = octokit_client.contents(repo)
      # if found then returns false, and does not fail the metric
      return !repo_contents.any? {|file| file[:name] =~ /^contributing.md$/i}
    rescue Octokit::InvalidRepository, Octokit::NotFound
      # if repository not found, does fail the metric
      true
    end
  end

  def give_feedback(failure_result)
    if failure_result
      I18n.t(
        "quality_metrics.contributing_file.failure"
      )
    else
      I18n.t(
        "quality_metrics.contributing_file.success"
      )
    end
  end
end
