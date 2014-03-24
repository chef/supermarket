class SupportedPlatform < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :cookbook_version

  # Validations
  # --------------------
  validates :name, presence: true
  validates :cookbook_version, presence: true
  validate :platform_has_valid_version_constraint

  private

  #
  # Check to see if the version constraint is a valid Chef version constraint.
  # If not, it adds an error on the +version_constraint+ attribute.
  #
  def platform_has_valid_version_constraint
    Chef::VersionConstraint.new(version_constraint)
  rescue Chef::Exceptions::InvalidVersionConstraint
    errors.add(
      :version_constraint,
      I18n.t(
        'api.error_messages.invalid_version_constraint',
        name: name,
        version_constraint: version_constraint
      )
    )
  end
end
