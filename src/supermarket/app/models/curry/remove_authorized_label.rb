require 'octokit'
require 'set'

#
# Removes the ENV['CURRY_SUCCESS_LABEL'] label from a Pull Request
#
class Curry::RemoveAuthorizedLabel
  #
  # Creates a new +Curry::RemoveAuthorizedLabel+
  #
  # @param octokit [Octokit::Client]
  # @param pull_request [Curry::PullRequest]
  #
  def initialize(octokit, pull_request)
    @octokit = octokit
    @pull_request = pull_request
  end

  #
  # Performs the action of removing the label
  #
  def call
    begin
      if existing_labels.include?(ENV['CURRY_SUCCESS_LABEL'])
        @octokit.remove_label(
          @pull_request.repository.full_name,
          @pull_request.number,
          ENV['CURRY_SUCCESS_LABEL']
        )
      end
    rescue Octokit::NotFound
      Rails.logger.info 'Label not on issue.'
    end
  end

  private

  #
  # The set of labels on the Pull Request
  #
  # @return [Set<String>]
  #
  def existing_labels
    Set.new(
      @octokit.labels_for_issue(
        @pull_request.repository.full_name,
        @pull_request.number
      ).map(&:name)
    )
  end
end
