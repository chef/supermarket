class IclaSignature < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :user

  # Validations
  # --------------------
  validates_presence_of :user

  # Callbacks
  # --------------------

end
