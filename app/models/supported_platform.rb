require 'active_model/validations/chef_version_constraint_validator'

class SupportedPlatform < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :cookbook_version_platforms
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
    platform = where(name: name, version_constraint: version).first

    if platform
      platform
    else
      create! name: name, version_constraint: version
    end
  end
end
