class Contributor < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :organization
  belongs_to :user

  # Validations
  # --------------------
  validates_uniqueness_of :user_id, scope: :organization_id

  #
  # Returns the +Contributor+'s primary email address.
  #
  # @return [String] if the user has a primary email.
  #
  # @return [nil] if the user does not have a primary email.
  #
  def email
    user.email
  end

  #
  # Determine if the if the instance of +Contributor+ is the only admin of
  # its +Organization+
  #
  # @return [Boolean]
  #
  def only_admin?
    admin? && organization.admins.count == 1
  end
end
