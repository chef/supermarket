module SupportedPlatformsHelper
  #
  # Determines the correct icon to use for a given platform
  #
  # @example
  #   platform = SupportedPlatform.new(name: 'ubuntu')
  #   supported_platform_icon(platform) == 'U'
  #
  # @return [String] the icon
  #
  def supported_platform_icon(platform)
    platform.name[0].upcase
  end
end
