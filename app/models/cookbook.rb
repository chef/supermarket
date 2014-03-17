class Cookbook < ActiveRecord::Base
  include PgSearch

  scope :with_name, ->(name) { where('lower(name) = ?', name.to_s.downcase) }
  scope :recently_updated, -> { where(updated_at: 30.days.ago..Time.now) }

  # Search
  # --------------------
  pg_search_scope(
    :search,
    against: {
      name: 'A',
      description: 'B',
      maintainer: 'D'
    },
    associated_against: {
      category: :name
    },
    using: {
      tsearch: { prefix: true, dictionary: 'english' }
    }
  )

  # Callbacks
  # --------------------
  before_validation :copy_name_to_lowercase_name

  # Associations
  # --------------------
  has_many :cookbook_versions, -> { order(created_at: :desc) }, dependent: :destroy
  belongs_to :category

  # Validations
  # --------------------
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :lowercase_name, presence: true, uniqueness: true
  validates :maintainer, presence: true
  validates :description, presence: true

  #
  # Returns the name of the +Cookbook+ parameterized.
  #
  # @return [String] the name of the +Cookbook+ parameterized
  #
  def to_param
    name.parameterize
  end

  #
  # Return the specified +CookbookVersion+. Raises an
  # +ActiveRecord::RecordNotFound+ if the version does not exist. The first line
  # of the method translates the version from a parameter friendly verison
  # (2_0_1) to a dot version (2.0.1).
  #
  # @example
  #   cookbook.get_version!("1_0_0")
  #   cookbook.get_version!("latest")
  #
  # @param version [String] the version of the Cookbook to find. Pass in
  #                         'latest' to return the latest version of the
  #                         cookbook.
  #
  # @return [CookbookVersion] the +CookbookVersion+ with the version specified
  #
  def get_version!(version)
    version.gsub!(/_/, '.')

    if version == 'latest'
      cookbook_versions.first!
    else
      cookbook_versions.find_by!(version: version)
    end
  end

  #
  # Saves a new version of the cookbook as specified by the given metadata and
  # tarball
  #
  # @raise [ActiveRecord::RecordInvalid] if the new version fails validation
  # @raise [ActiveRecord::RecordNotUnique] if the new version is a duplicate of
  #   an existing version for this cookbook
  #
  # @return [TrueClass]
  #
  # @param metadata [CookbookUpload::Metadata] the cookbook metadata
  # @param tarball [File] the cookbook artifact
  #
  def publish_version!(metadata, tarball)
    transaction do
      self.maintainer = metadata.maintainer
      self.description = metadata.description
      save!

      cookbook_versions.create!(
        license: metadata.license,
        version: metadata.version,
        tarball: tarball
      )
    end

    true
  end

  private

  #
  # Populates the +lowercase_name+ attribute with the lowercase +name+
  #
  # This exists until Rails schema dumping supports Posgres's expression
  # indices, which would allow us to create an index on LOWER(name). To do that
  # now, we'd have to use the raw SQL schema dumping functionality, which is
  # less-than ideal
  #
  def copy_name_to_lowercase_name
    self.lowercase_name = name.to_s.downcase
  end
end
