require 'libarchive'

class CookbookUpload
  #
  # This class provides access to cookbook archives. In particular, it supports
  # finding entries in the archive which have a path matching some regular
  # expression, and it can read the contents of files given their path. These
  # are the two primary operations required by Supermarket to locate and
  # process metadata and README files.
  #
  class Archive
    #
    # Indicates that the uploaded archive may not be an upload, since it does
    # not have a +path+
    #
    NoPath = Class.new(RuntimeError)

    #
    # Indicates that the source could not be processed
    #
    Error = Class.new(RuntimeError)

    #
    # Creates a new Archive
    #
    # @param source [File] the source archive
    #
    def initialize(source)
      @source = source
    end

    #
    # Returns the paths of entries in the archive which match the given regular expression
    #
    # @param pattern [Regexp]
    #
    # @return [Array<String>] matching paths
    #
    def find(pattern)
      matches = []

      each do |entry, _|
        next unless entry.pathname.match(pattern)

        matches << entry.pathname
      end

      matches
    end

    #
    # Reads the contents of the file at the given path
    #
    # @param path [String]
    #
    # @return [String] the contents if a file exists at the given path
    # @return [nil] if no such file exists
    #
    def read(path)
      match = nil

      each do |entry, archive|
        next unless entry.pathname == path

        match = archive.read_data

        break
      end

      match
    end

    private

    #
    # Iterates through each entry in the source archive
    #
    # @raise [NoPath] if the source has no path
    # @raise [Error] if the source is not a compatible archive
    #
    # @yieldparam [::Archive::Entry] entry
    # @yieldparam [::Archive::Reader] archive
    #
    # @example
    #   archive = CookbookUpload::Archive.new(tarball)
    #   archive.each do |entry, archive|
    #     puts "#{entry.pathname} has the following content:\n#{archive.read_data}"
    #   end
    #
    def each
      raise NoPath unless @source.respond_to?(:path)

      begin
        ::Archive.read_open_filename(@source.path) do |archive|
          loop do
            entry = archive.next_header

            if entry
              yield entry, archive
            else
              break
            end
          end
        end
      rescue ::Archive::Error => e
        raise Error, e.message
      end
    end
  end
end
