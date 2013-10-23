class Account < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates_presence_of :user
  validates_presence_of :uid
  validates_presence_of :username
  validates_presence_of :oauth_token
  validates_presence_of :oauth_secret
  validates_presence_of :oauth_expires

  # Callbacks
  # --------------------

end
