require 'active_model/validations/chef_version_validator'

class CookbookVersion < ApplicationRecord
  include SeriousErrors

  # Associations
  # --------------------
  has_many :cookbook_version_platforms, dependent: :destroy
  has_many :supported_platforms, through: :cookbook_version_platforms
  has_many :cookbook_dependencies, dependent: :destroy
  has_many :metric_results, -> { includes :quality_metric }, inverse_of: :cookbook_version

  belongs_to :cookbook
  belongs_to :user, -> { includes :chef_account }, inverse_of: :cookbook_versions
  has_one :owner, -> { includes :chef_account }, through: :cookbook

  # Attachments
  # --------------------
  has_attached_file :tarball

  # Validations
  # --------------------
  validates :license, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :readme, presence: true
  validates :version, presence: true, uniqueness: { scope: :cookbook }, chef_version: true
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
                     'application/cap', 'application/x-tar-gz',
                     'application/postscript', 'application/x-targz'],
      message: ->(_, info) { "can not be #{info[:value]}." }
    }
  )

  # Delegations
  # --------------------
  delegate :name, :owner, to: :cookbook

  #
  # Returns the verison of the +CookbookVersion+
  #
  # @example
  #   cookbook_version = CookbookVersion.new(version: '1.0.2')
  #   cookbook_version.to_param # => '1.0.2'
  #
  # @return [String] the version of the +CookbookVersion+
  #
  def to_param
    version
  end

  #
  # The total number of times this version has been downloaded
  #
  # @return [Fixnum]
  #
  def download_count
    web_download_count + api_download_count
  end

  # Create a link between a SupportedPlatform and a CookbookVersion
  #
  # @param name [String] platform name
  # @param version [String] platform version
  #
  def add_supported_platform(name, version)
    platform = SupportedPlatform.for_name_and_version(name, version)
    CookbookVersionPlatform.create! supported_platform: platform, cookbook_version: self
  end

  def cookbook_artifact_url
    if Paperclip::Attachment.default_options[:storage] == 's3'
      ENV['S3_URLS_EXPIRE'].present? ? tarball.expiring_url(ENV['S3_URLS_EXPIRE'].to_i) : tarball.url
    else
      "#{Supermarket::Host.full_url}#{tarball.url}"
    end
  end

  def published_by
    user || cookbook.owner
  end

  def metric_result_pass_rate
    total_metric_results = metric_results.count
    if total_metric_results.positive?
      ((metric_results.where(failure: false).count / total_metric_results.to_f) * 100).round(0)
    else
      '-'
    end
  end
end
