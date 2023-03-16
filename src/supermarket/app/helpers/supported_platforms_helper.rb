module SupportedPlatformsHelper
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
      "aix" => "aix",
      "almalinux" => "almalinux",
      "amazon" => "aws",
      "centos" => "centos",
      "debian" => "debian",
      "fedora" => "fedora",
      "freebsd" => "freebsd",
      "linuxmint" => "linuxmint",
      "mac_os_x" => "macosx",
      "mac_os_x_server" => "macosx",
      "oracle" => "oracle",
      "opensuse" => "suse",
      "opensuseleap" => "suse",
      "redhat" => "redhat",
      "rocky" => "rocky",
      "scientific" => "scientific",
      "smartos" => "smartos",
      "suse" => "suse",
      "ubuntu" => "ubuntu",
      "windows" => "windows",
      "zlinux" => "zlinux",
    }.fetch(platform.name.parameterize(separator: "_"), "generic")
  end
end
