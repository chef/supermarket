class CookbookVersion < ActiveRecord::Base
  belongs_to :cookbook

  validates :license, presence: true
  validates :version, presence: true
  validates :description, presence: true
  validates :cookbook_id, presence: true

  #
  # Returns the verison of the +CookbookVersion+ with underscores replacing the
  # dots.
  #
  # @example
  #   cookbook_version.to_param # => '1_0_2
  #
  # @return [String] the version of the +CookbookVersion+
  def to_param
    version.gsub(/\./,'_')
  end
end
