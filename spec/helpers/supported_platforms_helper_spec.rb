require 'spec_helper'

describe SupportedPlatformsHelper do
  describe '#supported_platform_icon' do
    it 'returns the corresponding platform icon character' do
      platform = SupportedPlatform.new(name: 'ubuntu')

      expect(helper.supported_platform_icon(platform)).to eql('M')
    end
  end
end
