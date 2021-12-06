module Utils
  class FileFormat
    class << self
      def get_mime_type(file_path:)
        IO.popen(["file", "--mime-type", "--brief", file_path]) { |io| io.read.chomp }
      end
    end
  end
end