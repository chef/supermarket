class Curry::UnknownCommitter < ActiveRecord::Base

  has_many :unknown_pull_request_committers
  has_many :pull_requests, through: :unknown_pull_request_committers

  scope :with_known_email, -> { where('email IS NOT ?', nil) }
  scope :with_known_login, -> { where('login IS NOT ?', nil) }

  scope :with_email, ->(email) { where(email: email) }
  scope :with_login, ->(login) { where(login: login) }

end
