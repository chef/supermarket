class Account < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates_presence_of :user
  validates_presence_of :uid
  validates_presence_of :provider
  validates_presence_of :oauth_token

  # Scope
  # --------------------
  scope :for, ->(id) { where(provider: id) }
end
