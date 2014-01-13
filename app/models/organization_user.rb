class OrganizationUser < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :organization
  belongs_to :user
end
