class CookbookVersionPlatform < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :cookbook_version
  belongs_to :supported_platform

  # Validations
  # --------------------
  validates :cookbook_version, presence: true
  validates :supported_platform, presence: true
end
