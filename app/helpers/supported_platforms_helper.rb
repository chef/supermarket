module SupportedPlatformsHelper
  #
  # Determines the correct icon to use for a given platform
  #
  # @example
  #   platform = SupportedPlatform.new(name: 'ubuntu')
  #   supported_platform_icon(platform) == 'U'
  #
  # TODO: Add fallback icon key, currently it just falls back to empty string.
  #
  # @return [String] the icon
  #
  def supported_platform_icon(platform)
    {
      'aws' => 'A',
      'centos' => 'B',
      'debian' => 'C',
      'fedora' => 'D',
      'freebsd' => 'E',
      'linux_mint' => 'F',
      'mac_osx' => 'G',
      'oracle' => 'H',
      'red_hat' => 'I',
      'scientific' => 'J',
      'smartos' => 'K',
      'suse' => 'L',
      'ubuntu' => 'M',
      'windows' => 'N'
    }.fetch(platform.name.parameterize('_'), '')
  end
end
