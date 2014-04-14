class CookbookVersion < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :supported_platforms, dependent: :destroy
  has_many :cookbook_dependencies, dependent: :destroy
  belongs_to :cookbook

  # Attachments
  #
  # If both a S3 bucket set in the application configuration use S3
  # otherwise use local storage.
  #
  # --------------------
  if Supermarket::Config.s3[:bucket].present?
    has_attached_file :tarball, storage: 's3', s3_credentials: Supermarket::Config.s3
  else
    has_attached_file :tarball
  end

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
end
