class CookbookCollaborator < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :cookbook
  belongs_to :user

  # Validations
  # --------------------
  validates :cookbook, presence: true
  validates :user, presence: true

  def self.with_cookbook_and_user(cookbook, user)
    where(cookbook_id: cookbook.id, user_id: user.id).first
  end
end
