require 'spec_helper'

describe ToolsHelper do
  describe '#pretty_type' do
    it 'correctly capitalizes DSC Resource' do
      expect(helper.pretty_type('dsc_resource')).to eql('DSC Resource')
    end

    it 'titleizes everything' do
      expect(helper.pretty_type('blueberry_muffin')).to eql('Blueberry Muffin')
    end
  end
end
