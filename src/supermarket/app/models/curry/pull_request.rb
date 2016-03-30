class Curry::PullRequest < ActiveRecord::Base
  belongs_to :repository
  has_many :pull_request_updates, dependent: :destroy

  has_many :pull_request_commit_authors, dependent: :destroy
  has_many :commit_authors, through: :pull_request_commit_authors
  has_many :comments, class_name: 'Curry::PullRequestComment'

  belongs_to :maintainer, class_name: 'User'
  validates :number, presence: true, uniqueness: { scope: :repository_id }
  validates :repository_id, presence: true

  scope :numbered, ->(number) { where(number: number.to_s) }

  def unknown_commit_authors
    commit_authors.where(authorized_to_contribute: false)
  end
end
