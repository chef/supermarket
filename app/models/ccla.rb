class Ccla < Icla
  # Get the latest version based on the config value
  def self.latest
    find_by_version(Supermarket::Config.ccla_version)
  end
end
