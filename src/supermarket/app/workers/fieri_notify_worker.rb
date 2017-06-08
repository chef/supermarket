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
      'fieri_key' => ENV['FIERI_KEY'],
      'cookbook' =>
      {
        'name' => cookbook_version.name,
        'version' => cookbook_version.version,
        'artifact_url' => cookbook_version.cookbook_artifact_url
      }
    }

    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = data.to_json
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
  end
end
