class Account < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates :user, presence: true
  validates :uid, presence: true
  validates :provider, presence: true
  validates :oauth_token, presence: true
  validates :provider, uniqueness: { scope: :username }

  # Scope
  # --------------------
  scope :for, ->(id) { where(provider: id) }
  scope :with_username, ->(username) { where(username: username) }
end
