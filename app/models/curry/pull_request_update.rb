class Curry::PullRequestUpdate < ActiveRecord::Base
  validates :action, presence: true
  validates :pull_request_id, presence: true

  belongs_to :pull_request

  #
  # Determine if the update closed the Pull Request
  #
  # @return [Boolean]
  #
  def closing?
    action == 'closed'
  end
end
