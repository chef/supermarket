require 'cookbook_upload/parameters'

class CookbookUpload
  #
  # Creates a new +CookbookUpload+.
  #
  # @param params [Hash] the upload parameters
  # @option params [String] :cookbook a JSON string which contains cookbook
  #   data. In particular, it should contain a +"category"+ key when
  #   deserialized
  # @option params [File] :tarball the cookbook tarball artifact
  #
  def initialize(params)
    @params = Parameters.new(params)
  end

  #
  # Finishes the upload process for this +CookbookUpload+'s parameters.
  #
  # @yieldparam errors [ActiveModel::Errors] errors which occured while
  #   finishing the upload. May be empty.
  # @yieldparam result [Cookbook, nil] the cookbook, if the upload succeeds
  #
  def finish
    result = nil

    if valid?
      upload_errors = ActiveModel::Errors.new([])

      begin
        result = cookbook.tap do |book|
          book.publish_version!(@params.metadata, @params.tarball)
        end
      rescue ActiveRecord::RecordNotUnique
        upload_errors.add(
          :base,
          I18n.t('api.error_messages.version_not_unique')
        )
      rescue ActiveRecord::RecordInvalid => e
        e.record.errors.full_messages.each do |message|
          upload_errors.add(:base, message)
        end
      end

      yield upload_errors, result if block_given?
    else
      yield errors, result if block_given?
    end
  end

  private

  def valid?
    errors.empty?
  end

  #
  # Returns any errors with the passed-in parameters.
  #
  # @return [ActiveModel::Errors]
  #
  def errors
    ActiveModel::Errors.new([]).tap do |e|
      @params.errors.full_messages.each do |message|
        e.add(:base, message)
      end

      if category.nil?
        message = I18n.t(
          'api.error_messages.non_existent_category',
          category_name: @params.category_name
        )

        e.add(:base, message)
      end
    end
  end

  #
  # The cookbook specified by the uploaded metadata. If no such cookbook
  # exists, the returned cookbook will only exist in-memory.
  #
  # @return [Cookbook]
  #
  def cookbook
    Cookbook.with_name(@params.metadata.name).first_or_initialize.tap do |book|
      book.name = @params.metadata.name
      book.category = category
    end
  end

  #
  # The category specified by the cookbook params.
  #
  # @return [Category] if such a category exists
  # @return [NilClass] if no such category exists
  #
  def category
    Category.with_name(@params.category_name).first
  end
end
