require 'spec_helper'

describe CookbookVersionsHelper do
  describe '#render_document' do
    it 'converts markdown to html when the extension is "md"' do
      expect(render_document('*hi*', 'md')).to eql("<p><em>hi</em></p>\n")
    end

    it 'returns the content if no extension is specified' do
      expect(render_document('_hi_', '')).to eql('_hi_')
    end
  end
end
