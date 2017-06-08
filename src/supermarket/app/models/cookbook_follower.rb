class CookbookFollower < ApplicationRecord
  # Associations
  # --------------------
  belongs_to :cookbook, counter_cache: true
  belongs_to :user

  # Validations
  # --------------------
  validates :cookbook, presence: true
  validates :user, presence: true
  validates :cookbook_id, uniqueness: { scope: :user_id }
end
