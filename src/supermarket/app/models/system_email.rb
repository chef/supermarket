class SystemEmail < ApplicationRecord
  # Associations
  # --------------------
  has_many :email_preferences, dependent: :destroy
  has_many :subscribed_users, through: :email_preferences, source: :user

  # Validations
  # --------------------
  validates :name, presence: true, uniqueness: true
end
