#
# represents a "collaboration" - linking a thing that can be collaborated on
# (e.g. a "resourceable thing" like a cookbook or tool) with the humans that
# help work on that thing
#
class Collaborator < ApplicationRecord
  # Associations
  # --------------------
  belongs_to :resourceable, polymorphic: true
  belongs_to :user
  belongs_to :group, optional: true

  # Validations
  # --------------------
  validates :resourceable, presence: true
  validates :user, presence: true
  validates :resourceable_id, uniqueness: { scope: [:user_id, :resourceable_type, :group_id] }

  # Accessors
  # --------------------
  attr_accessor :user_ids
  attr_accessor :group_ids

  COOKBOOK_TYPE = "Cookbook".freeze

  #
  # Transfers ownership of this cookbook to this user. The existing owner is
  # automatically demoted to a collaborator.
  #
  def transfer_ownership
    transaction do
      Collaborator.create resourceable: resourceable, user: resourceable.owner
      resourceable.update(owner: user)
      destroy
    end
  end

  #
  # Returns the ineligible users for collaboration for a given resource.
  #
  def self.ineligible_collaborators_for(resource)
    [resource.direct_collaborator_users, resource.owner].flatten
  end

  #
  # Returns the ineligible users for ownership for a given resource.
  #
  def self.ineligible_owners_for(resource)
    [resource.owner]
  end
end
