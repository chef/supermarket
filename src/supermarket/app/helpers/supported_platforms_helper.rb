module SupportedPlatformsHelper

  #
  # Returns an array of all known platforms to Supermarket
  #
  # @example
  #   puts known_platforms.join(',')
  #
  #
  # @return [Array] platforms
  #
  def known_platforms
    %(aix
      amazon
      cento
      debian
      fedora
      freebsd
      gentoo
      mac_os_x
      omnios
      openbsd
      opensuse
      opensuseleap
      oracle
      redhat
      ubuntu
      scientific
      smartos
      solaris
      suse
      windows
      zlinux)
  end


  #
  # Determines the correct icon to use for a given platform
  #
  # @example
  #   platform = SupportedPlatform.new(name: 'mac_os_x_server')
  #   supported_platform_icon(platform) == 'macosx'
  #
  #
  # @return [String] the icon
  #
  def supported_platform_icon(platform)
    {
      'aix' => 'aix',
      'amazon' => 'aws',
      'centos' => 'centos',
      'debian' => 'debian',
      'fedora' => 'fedora',
      'freebsd' => 'freebsd',
      'linuxmint' => 'linuxmint',
      'mac_os_x' => 'macosx',
      'mac_os_x_server' => 'macosx',
      'oracle' => 'oracle',
      'opensuse' => 'suse',
      'opensuseleap' => 'suse',
      'redhat' => 'redhat',
      'scientific' => 'scientific',
      'smartos' => 'smartos',
      'suse' => 'suse',
      'ubuntu' => 'ubuntu',
      'windows' => 'windows',
      'zlinux' => 'zlinux'
    }.fetch(platform.name.parameterize('_'), 'generic')
  end
end
