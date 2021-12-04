require "ffi-libarchive"
require "filemagic"

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
    class NoPath < RuntimeError; end

    #
    # Indicates that the source could not be processed
    #
    class Error < RuntimeError; end
    class CorruptTarball < Error; end
    class NotGzipped < Error; end

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

      each_entry do |entry, _|
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

      each_entry do |entry, contents|
        next unless entry.pathname == path

        match = contents

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
    # @yieldparam [::String] contents
    #
    # @example
    #   archive = CookbookUpload::Archive.new(tarball)
    #   archive.each do |entry|
    #     puts "#{entry.full_name} has the following content:\n#{entry.read}"
    #   end
    #
    def each_entry
      raise NoPath unless @source.respond_to?(:path)
      raise NotGzipped unless gzipped?

      begin
        ::Archive::Reader.open_filename(@source.path) do |tar|
          tar.each_entry_with_data do |entry, data|
            contents = data.is_a?(String) ? data : ""
            yield entry, contents
          end
        end
      rescue ::Archive::Error => e
        case e.message
        when /Damaged tar archive/
          raise CorruptTarball, e.message
        else
          raise e
        end
      end
    end

    #
    # Determines whether a file at a path is gzipped or not
    #
    # @return true/false
    #
    def gzipped?
      # mime types returned for GZips have looked like:
      #   "application/x-gzip; charset=binary" on macOS
      #   "application/gzip; charset=binary" on Ubuntu
      # This regex settled on after tinkering in Rubular.
      # ref: https://rubular.com/r/bNfFNbNYqqFof4
      #
      # It's possible the implementation for this detection will need
      # to change. Please feel empowered, dear readers of the future.
      FileFormat.get_mime_type(file_path: @source.path).match? %r{application\/x?-?gzip}
    end
  end
end
