class Category < ApplicationRecord
  scope :with_name, ->(name) { where(name: name.titleize) }

  # Callbacks
  # --------------------
  before_save :set_slug

  # Associations
  # --------------------
  has_many :cookbooks, dependent: :nullify

  #
  # Returns the name of the +Category+ parameterized.
  #
  # @return [String] the name of the +Category+ parameterized
  #
  def to_param
    slug
  end

  private

  #
  # Sets the slug to the parameterized name of the +Category+, if one doesn't
  # already exist
  #
  def set_slug
    self.slug = name.parameterize if slug.blank?
  end
end
