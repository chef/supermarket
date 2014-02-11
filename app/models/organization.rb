class Organization < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :contributors
  has_many :users, through: :contributors
  has_many :invitations
  has_many :ccla_signatures

  #
  # Returns all admin contributors.
  #
  # @return [ActiveRecord::AssociationRelation]
  #
  def admins
    contributors.where(admin: true)
  end

  #
  # Returns a name for an organization derived from its most recently signed CCLA.
  #
  # @return [String]
  #
  def name
    latest_ccla_signature.company
  end

  #
  # Retrieve the latest CCLA signature if they have signed a CCLA.
  #
  # @return [CclaSignature]
  #
  def latest_ccla_signature
    ccla_signatures.order(:signed_at).last
  end
end
