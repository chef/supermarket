require 'active_model/validations/chef_version_constraint_validator'

class SupportedPlatform < ApplicationRecord
  include SeriousErrors

  # Associations
  # --------------------
  has_many :cookbook_version_platforms, dependent: :destroy
  has_many :cookbook_versions, through: :cookbook_version_platforms

  # Validations
  # --------------------
  validates :name, presence: true, uniqueness: { scope: :version_constraint }
  validates :version_constraint, chef_version_constraint: true

  #
  # Creates or returns a SupportedPlatform, as necessary, given the name and
  # version information.
  #
  # @param name [String] the platform name
  # @param version [String] the version constraint
  #
  def self.for_name_and_version(name, version)
    find_or_create_by!(name: name, version_constraint: version)
  end
end
