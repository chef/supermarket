require 'sidekiq'
require 'net/http'
require 'octokit'

class VersionTagWorker < SourceRepoWorker
  include ::Sidekiq::Worker

  def perform(cookbook_json, cookbook_name, cookbook_version)
    evaluate_result = evaluate(cookbook_json, cookbook_version)

    Net::HTTP.post_form(
      URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/quality_metrics/version_tag_evaluation"),
      fieri_key: ENV['FIERI_KEY'],
      cookbook_name: cookbook_name,
      cookbook_version: cookbook_version,
      version_tag_failure: evaluate_result,
      version_tag_feedback: give_feedback(evaluate_result)
    )
  end

  private

  def evaluate(cookbook_json, cookbook_version)
    repo = source_repo(cookbook_json)

    # if no match for repo from #source_user_repo, fails metric
    return true if repo.blank?

    tags = tag_names(repo)

    # community cookbook version tags sometimes are in the format '2.5.4'
    # and sometimes are in the format of 'v2.5.4'
    if tags.include?(cookbook_version) || tags.include?("v#{cookbook_version}")
      # if an appropriate tag is found, does not fail the metric
      false
    else
      true
    end
  end

  def tag_names(repo)
    octokit_client.tags(repo).map { |tag| tag['name'] }
  rescue Octokit::NotFound
    []
  end

  def give_feedback(failure_result)
    if failure_result
      I18n.t(
        'quality_metrics.version_tag.failure'
      )
    else
      I18n.t(
        'quality_metrics.version_tag.success'
      )
    end
  end
end
