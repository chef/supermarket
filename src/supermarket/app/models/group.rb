class Group < ApplicationRecord
  include PgSearch::Model
  validates :name, presence: true, uniqueness: { case_sensitive: false } # rubocop:todo Rails/UniqueValidationWithoutIndex
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_many :group_resources, dependent: :destroy

  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true, dictionary: "english" }, trigram: { threshold: 0.2 } }
end
