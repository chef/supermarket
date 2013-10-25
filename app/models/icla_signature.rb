class IclaSignature < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates_presence_of :user

  # Scopes
  # --------------------
  scope :by_user, ->{ includes(:user).order('users.last_name, users.first_name') }

  # Callbacks
  # --------------------

end
