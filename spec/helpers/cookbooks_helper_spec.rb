require 'spec_helper'
require 'nokogiri'

describe CookbooksHelper do
  describe 'collaboration' do
    let(:jimmy) { create(:user) }
    let(:hank) { create(:user) }
    let(:sally) { create(:user) }
    let(:fanny) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: sally) }

    before do
      create(:icla_signature, user: hank)
      create(:icla_signature, user: fanny)
      create(:cookbook_collaborator, cookbook: cookbook, user: hank)
      create(:cookbook_collaborator, cookbook: cookbook, user: fanny)
    end

    describe '#owner?' do
      it 'should be true for the owner of a cookbook' do
        helper.stub(:current_user) { sally }
        expect(helper.owner?(cookbook)).to be_true
      end

      it 'should be false for anyone else' do
        helper.stub(:current_user) { jimmy }
        expect(helper.owner?(cookbook)).to be_false
      end
    end

    describe '#collaborator?' do
      it 'should be true when the current user is a collaborator and matches the collaborator in question' do
        helper.stub(:current_user) { hank }
        expect(helper.collaborator?(cookbook, hank)).to be_true
      end

      it 'should be false when the current user is a collaborator and does not match the collaborator in question' do
        helper.stub(:current_user) { fanny }
        expect(helper.collaborator?(cookbook, hank)).to be_false
      end

      it 'should be false when the current user is not a collaborator' do
        helper.stub(:current_user) { jimmy }
        expect(helper.collaborator?(cookbook, hank)).to be_false
      end
    end
  end

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
      cookbook = double(:cookbook, followed_by?: false, name: 'redis')
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/follow/)
    end

    it 'returns an unfollow button if the current user follows the given cookbook' do
      cookbook = double(:cookbook, followed_by?: true, name: 'redis')
      helper.stub(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/unfollow/)
    end

    it 'returns a call to action follow button if there is no current user' do
      cookbook = double(:cookbook, name: 'redis')
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
