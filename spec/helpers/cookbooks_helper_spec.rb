require 'spec_helper'
require 'nokogiri'

describe CookbooksHelper do
  describe '#contributor_removal_text' do
    let(:sally) { create(:user) }
    let(:hank) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: sally) }

    before do
      create(:cookbook_collaborator, cookbook: cookbook, user: hank)
    end

    it 'returns "Remove Contributor" if you are the owner' do
      helper.stub(:current_user) { sally }
      expect(helper.contributor_removal_text(cookbook)).to eql('Remove Contributor')
    end

    it 'returns "Remove Myself" if you are a contributor' do
      helper.stub(:current_user) { hank }
      expect(helper.contributor_removal_text(cookbook)).to eql('Remove Myself')
    end
  end

  describe '#follow_button_for' do
    it "returns a follow button if current user doesn't follow the given cookbook" do
      cookbook = double(
        :cookbook,
        followed_by?: false,
        cookbook_followers_count: 100,
        name: 'redis'
      )
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/follow/)
    end

    it 'returns a follow button with query params if any are given' do
      cookbook = double(
        :cookbook,
        followed_by?: false,
        cookbook_followers_count: 100,
        name: 'redis'
      )
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook, list: true)).to match(/\?list=true/)
    end

    it 'returns an unfollow button if the current user follows the given cookbook' do
      cookbook = double(
        :cookbook,
        followed_by?: true,
        cookbook_followers_count: 100,
        name: 'redis'
      )
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/unfollow/)
    end

    it 'returns a call to action follow button if there is no current user' do
      cookbook = double(:cookbook, cookbook_followers_count: 100, name: 'redis')
      helper.stub(:current_user) { false }

      expect(helper.follow_button_for(cookbook)).to match(/sign-in-to-follow/)
    end

    it 'uses the result of a passed block for the button text' do
      cookbook = double(:cookbook, cookbook_followers_count: 100, name: 'redis')
      helper.stub(:current_user) { false }

      block = proc { 'awesome text' }

      result = helper.follow_button_for(cookbook, &block)

      expect(result).to match(/awesome text/)
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

      expect(link['class']).to match(/active/)
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
