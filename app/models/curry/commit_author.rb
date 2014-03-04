class Curry::CommitAuthor < ActiveRecord::Base
  has_many :pull_request_commit_authors
  has_many :pull_requests, through: :pull_request_commit_authors

  scope :with_known_email, -> { where('email IS NOT ?', nil) }
  scope :with_known_login, -> { where('login IS NOT ?', nil) }

  scope :with_email, ->(email) { where(email: email) }
  scope :with_login, ->(login) { where(login: login) }

  #
  # Update the commit author's signed_cla? flag to true
  #
  # @return [Boolean]
  #
  def sign_cla!
    self.signed_cla = true
    save!
  end
end
