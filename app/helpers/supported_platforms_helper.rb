module SupportedPlatformsHelper
  #
  # Determines the correct icon to use for a given platform
  #
  # @example
  #   platform = SupportedPlatform.new(name: 'ubuntu')
  #   supported_platform_icon(platform) == 'U'
  #
  #
  # @return [String] the icon
  #
  def supported_platform_icon(platform)
    {
      'aix' => 'O',
      'amazon' => 'A',
      'centos' => 'B',
      'debian' => 'C',
      'fedora' => 'D',
      'freebsd' => 'E',
      'linuxmint' => 'F',
      'mac_os_x' => 'G',
      'mac_os_x_server' => 'G',
      'oracle' => 'H',
      'opensuse' => 'L',
      'redhat' => 'I',
      'scientific' => 'J',
      'smartos' => 'K',
      'suse' => 'L',
      'ubuntu' => 'M',
      'windows' => 'N'
    }.fetch(platform.name.parameterize('_'), 'P')
  end
end
