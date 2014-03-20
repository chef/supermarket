class Category < ActiveRecord::Base
  scope :with_name, ->(name) { where(name: name.titleize) }

  # Associations
  # --------------------
  has_many :cookbooks

  #
  # Returns the name of the +Category+ parameterized.
  #
  # @return [String] the name of the +Category+ parameterized
  #
  def to_param
    name.parameterize
  end
end
