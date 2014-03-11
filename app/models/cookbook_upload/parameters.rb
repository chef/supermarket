require 'active_model/errors'
require 'cookbook_upload/metadata'
require 'json'
require 'rubygems/package'

class CookbookUpload
  class Parameters
    #
    # @!attribute [r] tarball
    #   @return [File] The tarball parameter value
    #
    attr_reader :tarball

    #
    # Indicates that the uploaded tarball has no metdata.json entry
    #
    MissingMetadata = Class.new(RuntimeError)

    #
    # Indicates that the uploaded tarball may not be an upload, since it does
    # not have a +path+
    #
    TarballHasNoPath = Class.new(RuntimeError)

    #
    # Creates a new set of cookbook upload parameters
    #
    # @raise [KeyError] if any of the +:cookbook+ or +:tarball+ keys are missing
    #
    # @param params [Hash] the "raw" parameters
    # @option params [String] :cookbook a JSON string which specifies cookbook
    #   attributes; in particular, it should contain a +"category"+ key when
    #   deserialized
    # @option params [File] :tarball the cookbook tarball artifact
    #
    def initialize(params)
      @cookbook_data = params.fetch(:cookbook)
      @tarball = params.fetch(:tarball)
    end

    #
    # The category name given in the +:cookbook+ option. May be an empty string.
    #
    # @return [String]
    #
    def category_name
      parse_cookbook_json do |parsing_errors, json|
        if parsing_errors.any?
          ''
        else
          json.fetch('category', '').to_s
        end
      end
    end

    #
    # The metadata specified in the +:tarball+ option's metadata.json entry.
    # May be empty.
    #
    # @return [Metadata]
    #
    def metadata
      parse_tarball_metadata do |parsing_errors, metadata|
        if parsing_errors.any?
          Metadata.new
        else
          metadata
        end
      end
    end

    #
    # Determines if these parameters are valid.
    #
    # @return [TrueClass] if the parameters are valid
    # @return [FalseClass] if the parameters are invalid
    #
    def valid?
      errors.empty?
    end

    #
    # Returns any errors that occurred while parsing the +:cookbook+ JSON or
    # while parsing the +:tarball+ artifact
    #
    # @return [ActiveModel::Errors]
    #
    def errors
      ActiveModel::Errors.new([]).tap do |errors|
        parse_cookbook_json do |parsing_errors, _|
          parsing_errors.full_messages.each do |message|
            errors.add(:base, message)
          end
        end

        parse_tarball_metadata do |parsing_errors, _|
          parsing_errors.full_messages.each do |message|
            errors.add(:base, message)
          end
        end
      end
    end

    private

    #
    # Parses the tarball specified by the +:tarball+ option
    #
    # @yieldparam errors [ActiveModel::Errors] any errors that occurred while
    #   parsing and extracting the metadata
    # @yieldparam metadata [Metadata] the resulting metadata
    #
    def parse_tarball_metadata(&block)
      metadata = Metadata.new
      parsing_errors = ActiveModel::Errors.new([])

      begin
        raise TarballHasNoPath unless tarball.respond_to?(:path)

        Zlib::GzipReader.open(tarball.path) do |gzip|
          Gem::Package::TarReader.new(gzip) do |tar|
            entry = tar.find { |e| e.header.name.include?('metadata.json') }

            if entry
              metadata = Metadata.new(JSON.parse(entry.read))
            else
              raise MissingMetadata
            end
          end
        end
      rescue JSON::ParserError
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.metadata_not_json'))
        end
      rescue MissingMetadata
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.missing_metadata'))
        end
      rescue Zlib::GzipFile::Error
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.tarball_not_gzipped'))
        end
      rescue TarballHasNoPath
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.tarball_has_no_path'))
        end
      end

      block.call(parsing_errors, metadata)
    end

    #
    # Parses the JSON string given in the +:cookbook+ option
    #
    # @yieldparam errors [ActiveModel::Errors] any errors that occurred while
    #   parsing the JSON
    # @yieldparam json [Hash] the deserialized JSON
    #
    def parse_cookbook_json(&block)
      json = {}
      parsing_errors = ActiveModel::Errors.new([])

      begin
        json = JSON.parse(@cookbook_data)
      rescue JSON::ParserError
        parsing_errors.tap do |errors|
          errors.add(:base, I18n.t('api.error_messages.cookbook_not_json'))
        end
      end

      block.call(parsing_errors, json)
    end
  end
end
