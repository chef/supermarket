require 'spec_helper'

describe SupportedPlatformsHelper do
  describe '#supported_platform_icon' do
    it 'returns the first character of the platform name, uppercased' do
      platform = SupportedPlatform.new(name: 'ubuntu')

      expect(helper.supported_platform_icon(platform)).to eql('U')
    end
  end
end
