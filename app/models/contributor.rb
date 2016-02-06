class Contributor < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :organization
  belongs_to :user

  # Validations
  # --------------------
  validates :user_id, uniqueness: { scope: :organization_id }

  # Delegations
  # ____________________
  delegate :email, to: :user

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
