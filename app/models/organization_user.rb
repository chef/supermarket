class OrganizationUser < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :organization
  belongs_to :user

  #
  # Returns the +OrganizationUser+'s primary email address.
  #
  # @return [String] if the user has a primary email.
  #
  # @return [nil] if the user does not have a primary email.
  #
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
