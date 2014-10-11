require 'uri'

# Helper methods for the recipes
class Supermarket
  # Take a database URL and turn it into what we need for the database.yml.
  # Based on what Heroku does:
  # https://github.com/heroku/heroku-buildpack-ruby/blob/v34/lib/language_pack/ruby.rb#L440-503
  def self.parsed_database_url(url)
    begin
      uri = URI.parse(url)
    rescue URI::InvalidURIError
      raise "Invalid database_url"
    end

    raise '"postgres" is the only supported database type' unless uri.scheme == 'postgres'

    {
      'production' => {
        'adapter' => 'postgresql',
        'database' => (uri.path || '').split('/')[1],
        'username' => uri.user,
        'password' => uri.password,
        'host' => uri.host,
        'port' => uri.port,
      }
    }
  end
end
