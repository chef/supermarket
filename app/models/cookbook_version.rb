class CookbookVersion < ActiveRecord::Base
  # Associations
  # --------------------
  belongs_to :cookbook

  # Attachments
  # --------------------
  has_attached_file :tarball

  # Validations
  # --------------------
  validates :license, presence: true
  validates :version, presence: true, uniqueness: { scope: :cookbook }
  validates :cookbook, presence: true
  validates_attachment(
    :tarball,
    presence: true,
    content_type: {
      content_type: ['application/x-gzip', 'application/octet-stream']
    }
  )

  #
  # Returns the verison of the +CookbookVersion+ with underscores replacing the
  # dots.
  #
  # @example
  #   cookbook_version = CookbookVersion.new(version: '1.0.2')
  #   cookbook_version.to_param # => '1_0_2'
  #
  # @return [String] the version of the +CookbookVersion+
  #
  def to_param
    version.gsub(/\./, '_')
  end

  #
  # returns the README parsed with GitHub flavoured markdown
  #
  # TODO: implement this
  #
  def ghfmd_readme
    "hi, I am a great readme"
  end
end
