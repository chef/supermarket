class Organization < ActiveRecord::Base
  attr_accessor :combine_with_id

  # Associations
  # --------------------
  has_many :contributors, dependent: :destroy
  has_many :contributor_requests, dependent: :destroy
  has_many :users, through: :contributors
  has_many :invitations, dependent: :destroy
  has_many :ccla_signatures, dependent: :destroy

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

  #
  # Combine two organizations together by copying CCLA signatures, invitations
  # and contributors from one to the other. This also destroys the organzation
  # that's passed in.
  #
  # @param organization [Organization] The organization that we want to combine
  # with this one
  #
  def combine!(organization)
    transaction do
      [:ccla_signatures, :invitations].each do |assoc|
        organization.send(assoc).update_all(organization_id: id)
      end

      organization.contributors.
        where('user_id NOT IN (?)', contributors.pluck(:user_id)).
        update_all(organization_id: id, admin: false)

      organization.reload.destroy
    end
  end

  #
  # Returns the pending +ContributorRequest+s for the user. Eager loads the
  # associated +User+ # because it is used in the views to display and link to
  # the +User+.
  #
  # @return [Array<ContributorRequest>] array of pending +ContributorRequest+s
  #
  def pending_requests_to_join
    ContributorRequest.includes(
      :user
    ).where(
      organization: self
    ).select { |cr| cr.pending? }
  end
end
