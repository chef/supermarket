class Group < ApplicationRecord
  include PgSearch
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :group_members
  has_many :members, through: :group_members, source: :user
  has_many :group_resources

  pg_search_scope :search, against: :name, using: { tsearch: { prefix: true, dictionary: 'english' }, trigram: { threshold: 0.2 } }
end
