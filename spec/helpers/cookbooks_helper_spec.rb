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
end
