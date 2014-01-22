class OrganizationUser < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :organization
  belongs_to :user

  def email
    user.primary_email.try(:email)
  end

  #
  # Determine if the if the instance of +OrganizationUser+ is the only admin of
  # its +Organization+
  #
  # @return [Boolean]
  #
  def only_admin?
    admin? && organization.admins.count == 1
  end
end
