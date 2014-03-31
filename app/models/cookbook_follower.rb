class CookbookFollower < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :cookbook
  belongs_to :user

  # Validations
  # --------------------
  validates :cookbook, presence: true
  validates :user, presence: true
  validates :cookbook_id, uniqueness: { scope: :user_id }
end
