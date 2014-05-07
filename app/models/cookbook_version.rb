class CookbookVersion < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :supported_platforms, dependent: :destroy
  has_many :cookbook_dependencies, dependent: :destroy
  belongs_to :cookbook

  # Attachments
  # --------------------
  has_attached_file :tarball

  # Validations
  # --------------------
  validates :license, presence: true
  validates :description, presence: true
  validates :version, presence: true, uniqueness: { scope: :cookbook }
  validates_attachment(
    :tarball,
    presence: true,
    content_type: {
      content_type: ['application/x-gzip', 'application/gzip',
                     'application/octet-stream', 'application/x-tar',
                     'application/x-compressed-tar', 'application/x-gtar',
                     'application/x-bzip2', 'application/gzipped-tar',
                     'application/x-compressed', 'application/download',
                     'application/x-gtar-compressed', 'application/zip',
                     'application/x-bzip', 'application/x-zip-compressed',
                     'application/cap', 'application/x-tar-gz']
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
end
