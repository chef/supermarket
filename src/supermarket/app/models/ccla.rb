class Ccla < ActiveRecord::Base
  validates :version, uniqueness: true

  # Get the latest version based on the config value
  def self.latest
    find_by_version(ENV['CCLA_VERSION'])
  end
end
