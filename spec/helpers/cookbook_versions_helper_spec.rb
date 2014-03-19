require 'spec_helper'

describe CookbookVersionsHelper do
  describe '#render_readme' do
    it 'converts markdown to html when the extension is "md"' do
      expect(render_readme('*hi*', 'md')).to eql("<p><em>hi</em></p>\n")
    end

    it 'returns the content if no extension is specified' do
      expect(render_readme('_hi_', '')).to eql("_hi_")
    end
  end
end
