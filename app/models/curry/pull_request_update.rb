class Curry::PullRequestUpdate < ActiveRecord::Base
  validates :action, presence: true
  validates :pull_request_id, presence: true

  belongs_to :pull_request

  # The actions that we want Curry to take action on when a pull request is
  # updated
  WHITE_LIST_ACTIONS = %w(opened reopened synchronize)

  #
  # Determine if the update is something that should require Curry to take
  # action
  #
  # @return [Boolean] whether or not this is an update that requires action
  #
  def requires_action?
    WHITE_LIST_ACTIONS.include?(action)
  end
end
