require 'open-uri'
require 'rubygems/package'
require 'foodcritic'

class CookbookArtifact
  #
  # Accessors
  #
  attr_accessor :url, :archive, :directory, :job_id, :work_dir

  #
  # Initializes a +CookbookArtifact+ downloading and unarchiving the
  # artifact from the given url.
  #
  # @param [String] the url where the artifact lives
  # @param [String] the id of the job in charge of processing the artifact
  #
  def initialize(url, jid)
    @url = url
    @job_id = jid || 'nojobid'
    @work_dir = File.join(Dir.tmpdir, job_id)
    @archive = download
    @directory = unarchive
  end

  #
  # Runs FoodCritic against an artifact.
  #
  # @return [Boolean] whether or not FoodCritic passed
  # @return [String] the would be command line out from FoodCritic
  #
  def criticize
    args = [directory, "-f #{ENV['FOODCRITIC_FAIL_TAGS']}"]
    ENV['FOODCRITIC_TAGS'].split.each do |tag|
      args.push("-t #{tag}")
    end if ENV['FOODCRITIC_TAGS']
    cmd = FoodCritic::CommandLine.new(args)
    result, _status = FoodCritic::Linter.run(cmd)

    [result.to_s, result.failed?]
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
    File.open(Tempfile.new('archive'), 'wb') do |saved_file|
      open(url, 'rb') do |read_file|
        saved_file.write(read_file.read)
      end
      saved_file
    end
  end

  #
  # Unarchives an artifact into the tmp directory. The unarchived artifact
  # will be deleted when the +CookbookArtifact+ is garbage collected.
  #
  # @return [String] the directory where the unarchived artifact lives.
  #
  def unarchive
    Gem::Package::TarReader.new(Zlib::GzipReader.open(archive.path)) do |tar|
      root = File.expand_path(work_dir, tar.first.header.name.split('/')[0])
      tar.rewind

      tar.each do |entry|
        next unless entry.file?

        destination_file = File.join(work_dir, entry.header.name)
        destination_dir = File.dirname(destination_file)

        FileUtils.mkdir_p destination_dir unless File.directory?(destination_dir)

        file = File.open(destination_file, 'w+')
        file << entry.read
        file.close
      end

      return root
    end
  end
end
