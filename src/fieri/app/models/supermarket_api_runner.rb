require 'sidekiq'
require 'net/http'

class SupermarketApiRunner
  def cookbook_api_response(cookbook_name)
    get_api_response(cookbook_api_uri(cookbook_name))
  end

  def cookbook_version_api_response(cookbook_name, version)
    get_api_response(cookbook_version_api_uri(cookbook_name, version))
  end

  private

  def cookbook_api_uri(cookbook_name)
    URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{cookbook_name}")
  end

  def cookbook_version_api_uri(cookbook_name, cookbook_version)
    URI.parse("#{ENV['FIERI_SUPERMARKET_ENDPOINT']}/api/v1/cookbooks/#{cookbook_name}/versions/#{cookbook_version}")
  end

  def get_api_response(uri)
    Net::HTTP.get(uri)
  end
end
