require 'spec_helper'

describe CookbooksHelper do
  describe '#feed_title_for' do
    it 'returns a title for a category' do
      helper.stub(:params) { { category: 'other' } }
      expect(helper.feed_title).to eql('Other')
    end

    it 'returns a title for a sort order' do
      helper.stub(:params) { { order: 'updated_at' } }
      expect(helper.feed_title).to eql('Updated At')
    end

    it 'returns a fallback title' do
      helper.stub(:params) { {} }
      expect(helper.feed_title).to eql('All')
    end
  end
end
