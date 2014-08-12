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
      'cookbook_artrifact_url' => cookbook_version.tarball.url
    }

    response = Net::HTTP.post_form(uri, data)
  end
end
