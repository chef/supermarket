class OrganizationUser < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :organization
  belongs_to :user

  def email
    user.primary_email.try(:email)
  end
end
