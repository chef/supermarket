class Icla < ActiveRecord::Base
  validates_uniqueness_of :version

  # Get the latest version based on the config value
  def self.latest
    find_by_version(Supermarket::Config.icla_version)
  end
end
