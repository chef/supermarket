class Category < ActiveRecord::Base
  scope :with_name, ->(name) { where(name: name.titleize) }

  # Associations
  # --------------------
  has_many :cookbooks
end
