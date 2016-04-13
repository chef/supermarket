require 'spec_helper'

describe SupportedPlatformsHelper do
  describe '#supported_platform_icon' do
    it 'returns the corresponding platform name to match image filename' do
      platform = SupportedPlatform.new(name: 'ubuntu')

      expect(helper.supported_platform_icon(platform)).to eql('ubuntu')
    end

    it 'returns the shortened platform name for opensuse' do
      platform = SupportedPlatform.new(name: 'opensuse')

      expect(helper.supported_platform_icon(platform)).to eql('suse')
    end

    it 'returns the shortened name for Mac OS X Server' do
      platform = SupportedPlatform.new(name: 'mac_os_x_server')

      expect(helper.supported_platform_icon(platform)).to eql('macosx')
    end
  end
end
