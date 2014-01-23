class Organization < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :contributors
  has_many :users, through: :contributors
  has_many :invitations
  has_one  :ccla_signature

  # Validations
  # --------------------
  validates_presence_of :name

  def admins
    contributors.where(admin: true)
  end
end
