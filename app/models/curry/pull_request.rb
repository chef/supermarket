class Curry::PullRequest < ActiveRecord::Base

  belongs_to :repository
  has_many :pull_request_updates

  has_many :unknown_pull_request_committers
  has_many :unknown_committers, through: :unknown_pull_request_committers

  validates :number, presence: true
  validates :repository_id, presence: true

  scope :numbered, ->(number) { where(number: number.to_s) }

end
