require 'net/http'
require 'uri'

class FieriNotifyWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  #
  # Send a POST request to the configured +FIERI_URL+ when a Cookbook Version
  # is shared.
  #
  # @param [Integer] cookbook_version_id the id for the Cookbook
  #
  # @return [Boolean] whether or not the POST was successful
  #
  def perform(cookbook_version_id)
    cookbook_version = CookbookVersion.find(cookbook_version_id)

    uri = URI.parse(ENV['FIERI_URL'])

    data = {
      'cookbook_name' => cookbook_version.name,
      'cookbook_version' => cookbook_version.version,
      'cookbook_artifact_url' => cookbook_artifact_url(cookbook_version)
    }

    response = Net::HTTP.post_form(uri, data)
  end

  private

  def cookbook_artifact_url(cookbook_version)
    if s3_configured?
      cookbook_version.tarball.url
    else
      "#{Supermarket::Host.full_url}#{cookbook_version.tarball.url}"
    end
  end

  def s3_configured?
    %w(S3_BUCKET S3_ACCESS_KEY_ID S3_SECRET_ACCESS_KEY).all? do |key|
      ENV[key].present?
    end
  end
end
