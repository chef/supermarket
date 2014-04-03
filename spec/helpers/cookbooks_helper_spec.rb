require 'spec_helper'
require 'nokogiri'

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

  describe '#follow_button_for' do
    it "returns a follow button if current user doesn't follow the given cookbook" do
      cookbook = double(:cookbook, followed_by?: false)
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/follow/)
    end

    it 'returns an unfollow button if the current user follows the given cookbook' do
      cookbook = double(:cookbook, followed_by?: true)
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/unfollow/)
    end

    it 'returns a call to action follow button if there is no current user' do
      cookbook = double(:cookbook)
      helper.stub(:current_user) { false }

      expect(helper.follow_button_for(cookbook)).to match(/sign-in-to-follow/)
    end
  end

  describe '#link_to_sorted_cookbooks' do
    it 'returns an active link if the :order param is the given ordering' do
      helper.stub(:params) do
        { order: 'excellent', controller: 'cookbooks', action: 'index' }
      end

      link = Nokogiri::HTML(
        helper.link_to_sorted_cookbooks('Excellent', 'excellent')
      ).css('a').first

      expect(link['class']).to eql('active')
    end

    it 'returns a non-active link if the :order param is not the given ordering' do
      helper.stub(:params) do
        { order: 'excellent', controller: 'cookbooks', action: 'index' }
      end

      link = Nokogiri::HTML(
        helper.link_to_sorted_cookbooks('Not Excellent', 'not_excellent')
      ).css('a').first

      expect(link['class'].to_s.split(' ')).to_not include('active')
    end

    it 'generates a link to the current page with the given ordering' do
      helper.stub(:params) do
        { order: 'excellent', controller: 'cookbooks', action: 'index' }
      end

      link = Nokogiri::HTML(
        helper.link_to_sorted_cookbooks('Not Excellent', 'not_excellent')
      ).css('a').first

      expect(URI(link['href']).path).
        to eql(url_for(controller: 'cookbooks', action: 'index'))
      expect(URI(link['href']).query).to include('order=not_excellent')
    end
  end
end
