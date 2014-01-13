class Organization < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :invitations
  has_one  :ccla_signature

  # Validations
  # --------------------
  validates_presence_of :name
end
