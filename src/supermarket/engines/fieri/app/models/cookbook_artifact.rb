require "open-uri" unless defined?(OpenURI)
require "rubygems/package" unless defined?(Gem::Package)
require "mixlib/archive" unless defined?(Mixlib::Archive)
require "quality_metric/cookstyle_helpers"
require "openssl"

class CookbookArtifact
  #
  # Accessors
  #
  attr_accessor :url, :job_id, :work_dir

  FILE_SIZE_LIMIT = 2**20

  # This is needed since artifact url which is pointing to https
  # format cannot work with a strict ssl policy in a setup without
  # SSL cert. This check can be escaped if we are sure app will always have a
  # a valid SSL cert
  if ENV["CHEF_OAUTH2_VERIFY_SSL"].present? &&
     ENV["CHEF_OAUTH2_VERIFY_SSL"] == "false"
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  end

  #
  # Initializes a +CookbookArtifact+ downloading and unarchiving the
  # artifact from the given url.
  #
  # @param [String] the url where the artifact lives
  # @param [String] the id of the job in charge of processing the artifact
  #
  def initialize(url, jid)
    @url = url
    @job_id = jid || "nojobid"
    @work_dir = File.join(Dir.tmpdir, job_id)
  end

  #
  # downloads and untars a cookbook to the work_dir
  #
  def prep
    downloaded_tarball = download
    tar = Mixlib::Archive.new(downloaded_tarball.path)
    tar.extract(work_dir, perms: false)
  end

  # Runs cookstyle on a specific artifact
  # work_dir here represents the path where cookbook is uploaded
  def criticize
    prep
    result, status = CookstyleHelpers.process_artifact(work_dir)
    feedback = result.to_s.gsub("#{work_dir}/", "")
    [feedback, status]
  end

  #
  # Returns a list of binaries found in a cookbook
  #
  def binaries
    prep

    cookbook_files = Dir["#{work_dir}/**/*"]
    binaries_found = []

    cookbook_files.each do |file|
      case # rubocop:disable Style/EmptyCaseCondition
      when File.directory?(file)
        next
      when binary?(file)
        binaries_found << file.gsub("#{work_dir}/", "")
      when too_big?(file)
        binaries_found << file.gsub("#{work_dir}/", "") + " (size > #{FILE_SIZE_LIMIT} bytes)"
      end
    end

    binaries_found.join("\n")
  end

  #
  # Removes the unarchived directory returns nil if the directory
  # doesn't exist.
  #
  # @return [Fixnum] the status code from the operation
  #
  def cleanup
    FileUtils.remove_dir(work_dir, force: false)
  end

  private

  #
  # Downloads an artifact from a url and writes it to the filesystem.
  #
  # @return [Tempfile] the artifact
  #
  def download
    File.open(Tempfile.new("archive"), "wb") do |saved_file|
      URI.open(url, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
      saved_file
    end
  end

  def binary?(filepath)
    # This regex can go back to %r{^text\/} once we can run Ubuntu > 16.04
    # in our CI environments
    # need to check for application/xml explicitly because only versions of
    # libmagic < 5.26 are available on Ubuntu 14.04 and 16.04 which are our
    # CI (Travis and Automate) node platforms
    # s = File.read(filepath, 1024) || ""
    # s.count("\0") == 0 ? false : true
    Utils::FileFormat.get_mime_type(file_path: filepath) !~ %r{^text\/|inode\/x-empty|application\/xml|application\/json} # %r{^(text\/|inode\/x-empty|application\/xml)}
  end

  def too_big?(filepath)
    File.size(filepath) > FILE_SIZE_LIMIT
  end
end