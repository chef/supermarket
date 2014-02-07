class Organization < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :contributors
  has_many :users, through: :contributors
  has_many :invitations
  has_many :ccla_signatures

  def admins
    contributors.where(admin: true)
  end

  def name
    ccla_signatures.first.company
  end
end
