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
      alpine
      amazon
      arch
      cento
      cloudlinux
      debian
      fedora
      freebsd
      gentoo
      hpux
      ibm_powerkvm
      ios_xr
      linuxmint
      mac_os_x
      netbsd
      nexentacore
      nexus
      nexus_centos
      omnios
      openbsd
      openindiana
      opensolaris
      opensuse
      opensuseleap
      oracle
      parallels
      pidora
      raspbian
      redhat
      scientific
      slackware
      smartos
      solaris
      suse
      ubuntu
      windows
      wrlinux
      xenserver
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
