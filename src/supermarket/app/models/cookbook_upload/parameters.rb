require "active_model/errors"
require "cookbook_upload/archive"
require "cookbook_upload/metadata"
require "cookbook_upload/document"
require "json"
require "set"

class CookbookUpload
  class Parameters
    #
    # @!attribute [r] tarball
    #   @return [File] The tarball parameter value
    #
    attr_reader :tarball

    #
    # @!attribute [r] archive
    #   @return [Archive] An interface to +tarball+
    #
    attr_reader :archive

    #
    # Creates a new set of cookbook upload parameters
    #
    # @raise [KeyError] if any of the +:cookbook+ or +:tarball+ keys are missing
    #
    # @param params [Hash] the "raw" parameters
    # @option params [String] :cookbook a JSON string which specifies cookbook
    #   attributes
    # @option params [File] :tarball the cookbook tarball artifact
    #
    def initialize(params)
      @cookbook_data = params.fetch(:cookbook)
      @tarball = params.fetch(:tarball)
      @archive = Archive.new(@tarball)
    end

    #
    # The category name given in the +:cookbook+ option. May be an empty string.
    #
    # @return [String]
    #
    def category_name
      parse_cookbook_json do |parsing_errors, json|
        if parsing_errors.any?
          ""
        else
          json.fetch("category", "").to_s
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
    # The cookbook's readme. May be empty.
    #
    # @return [Document]
    #
    def readme
      extract_tarball_readme do |extraction_errors, readme|
        if extraction_errors.any?
          Document.new
        else
          readme
        end
      end
    end

    #
    # The cookbook's changelog. May be empty.
    #
    # @return [Document]
    #
    def changelog
      extract_tarball_changelog do |extraction_errors, changelog|
        if extraction_errors.any?
          Document.new
        else
          changelog
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
      return @errors if @errors

      error_messages = Set.new.tap do |messages|
        parse_cookbook_json do |parsing_errors, _|
          parsing_errors.full_messages.each do |message|
            messages << message
          end
        end

        parse_tarball_metadata do |parsing_errors, _|
          parsing_errors.full_messages.each do |message|
            messages << message
          end
        end

        extract_tarball_readme do |extraction_errors, _|
          extraction_errors.full_messages.each do |message|
            messages << message
          end
        end
      end

      @errors = ActiveModel::Errors.new([]).tap do |errors|
        error_messages.each do |error_message|
          errors.add(:base, error_message)
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
      errors = ActiveModel::Errors.new([])

      begin
        path = archive.find(%r{\A(\.\/)?[^\/]+\/metadata\.json\Z}).first

        if path
          metadata = Metadata.new(JSON.parse(archive.read(path)))
        else
          errors.add(:base, I18n.t("api.error_messages.missing_metadata"))
        end

        # transparently clean self-dependnecies from the uploaded metadata
        # (in the distant future this should be an error)
        metadata.dependencies.reject! { |key, _value| key == metadata.name }
      rescue JSON::ParserError
        errors.add(:base, I18n.t("api.error_messages.metadata_not_json"))
      rescue Dry::Struct::Error
        errors.add(:base, I18n.t("api.error_messages.invalid_metadata"))
      rescue Archive::NotGzipped
        errors.add(:base, I18n.t("api.error_messages.tarball_not_gzipped"))
      rescue Archive::NoPath
        errors.add(:base, I18n.t("api.error_messages.tarball_has_no_path"))
      rescue Archive::CorruptTarball => e
        errors.add(:base, I18n.t("api.error_messages.tarball_corrupt", error: e))
      end

      yield(errors, metadata)
    end

    #
    # Extracts the README from the tarball
    #
    # @yieldparam errors [ActiveModel::Errors] any errors that occurred while
    #   extracting the README
    # @yieldparam readme [Document] the cookbook's README
    #
    def extract_tarball_readme(&block)
      cookbook = metadata.name
      readme = nil
      errors = ActiveModel::Errors.new([])

      begin
        path = archive.find(%r{\A(\.\/)?#{cookbook}\/readme(\.\w+)?\Z}i).first

        if path
          readme = Document.new(
            contents: archive.read(path),
            extension: File.extname(path)[1..-1].to_s
          )

          if readme.contents.blank?
            readme = nil
            errors.add(:base, I18n.t("api.error_messages.missing_readme"))
          end
        else
          errors.add(:base, I18n.t("api.error_messages.missing_readme"))
        end
      rescue Archive::Error
        errors.add(:base, I18n.t("api.error_messages.tarball_not_gzipped"))
      rescue Archive::NoPath
        errors.add(:base, I18n.t("api.error_messages.tarball_has_no_path"))
      rescue ArgumentError, Gem::Package::TarInvalidError => e
        errors.add(:base, I18n.t("api.error_messages.tarball_corrupt", error: e))
      end

      yield(errors, readme)
    end

    #
    # Extracts the CHANGELOG from the tarball
    #
    # @yieldparam errors [ActiveModel::Errors] any errors that occurred while
    #   extracting the CHANGELOG
    # @yieldparam changelog [Document] the cookbook's CHANGELOG
    #
    def extract_tarball_changelog(&block)
      cookbook = metadata.name
      changelog = nil
      errors = ActiveModel::Errors.new([])

      begin
        path = archive.find(%r{\A(\.\/)?#{cookbook}\/changelog(\.\w+)?\Z}i).first

        changelog = if path
                      Document.new(
                        contents: archive.read(path),
                        extension: File.extname(path)[1..-1].to_s
                      )
                    else
                      Document.new
                    end
      rescue Archive::Error
        errors.add(:base, I18n.t("api.error_messages.tarball_not_gzipped"))
      rescue Archive::NoPath
        errors.add(:base, I18n.t("api.error_messages.tarball_has_no_path"))
      end

      yield(errors, changelog)
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
      errors = ActiveModel::Errors.new([])

      begin
        json = JSON.parse(@cookbook_data)
      rescue JSON::ParserError
        errors.add(:base, I18n.t("api.error_messages.cookbook_not_json"))
      end

      yield(errors, json)
    end
  end
end
