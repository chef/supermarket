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

  describe '#safe_updated_at' do
    it 'works if the collection has stuff in it' do
      expect(helper.safe_updated_at([create(:cookbook)])).to be <= Time.zone.now
    end

    it 'works if the collection is empty' do
      expect(helper.safe_updated_at([])).to be <= Time.zone.now
    end

    it 'works if the collection is nil' do
      expect(helper.safe_updated_at(nil)).to be <= Time.zone.now
    end
  end
end
