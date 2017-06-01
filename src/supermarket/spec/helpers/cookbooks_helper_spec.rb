require 'spec_helper'
require 'nokogiri'

describe CookbooksHelper do
  describe '#contingent_link' do
    it 'links to a cookbook using the cookbook name and version' do
      apt = create(:cookbook, name: 'apt')
      nginx = create(:cookbook, name: 'nginx')
      version = create(:cookbook_version, cookbook: nginx, version: '10.10.10')
      dependency = create(:cookbook_dependency, cookbook: apt, name: 'apt', cookbook_version: version)
      output = helper.contingent_link(dependency)
      expect(output).to match(/nginx 10\.10\.10/)
      expect(output).to match(%r{/cookbooks/nginx})
    end
  end

  describe '#latest_cookbook_version_url' do
    it 'should return an api url to the latest cookbook version' do
      apt = create(:cookbook, name: 'apt')
      create(:cookbook_version, cookbook: apt, version: '10.10.10')
      output = helper.latest_cookbook_version_url(apt.reload)
      expect(output).to eql('http://test.host/api/v1/cookbooks/apt/versions/10.10.10')
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
      allow(helper).to receive(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/follow/)
    end

    it 'returns a follow button with query params if any are given' do
      cookbook = double(
        :cookbook,
        followed_by?: false,
        cookbook_followers_count: 100,
        name: 'redis'
      )
      allow(helper).to receive(:current_user) { true }

      expect(helper.follow_button_for(cookbook, list: true)).to match(/\?list=true/)
    end

    it 'returns an unfollow button if the current user follows the given cookbook' do
      cookbook = double(
        :cookbook,
        followed_by?: true,
        cookbook_followers_count: 100,
        name: 'redis'
      )
      allow(helper).to receive(:current_user) { true }

      expect(helper.follow_button_for(cookbook)).to match(/unfollow/)
    end

    it 'returns a call to action follow button if there is no current user' do
      cookbook = double(:cookbook, cookbook_followers_count: 100, name: 'redis')
      allow(helper).to receive(:current_user) { false }

      expect(helper.follow_button_for(cookbook)).to match(/sign-in-to-follow/)
    end

    it 'uses the result of a passed block for the button text' do
      cookbook = double(:cookbook, cookbook_followers_count: 100, name: 'redis')
      allow(helper).to receive(:current_user) { false }

      block = proc { 'awesome text' }

      result = helper.follow_button_for(cookbook, &block)

      expect(result).to match(/awesome text/)
    end
  end

  describe '#link_to_sorted_cookbooks' do
    let(:params) do
      { order: 'excellent', controller: 'cookbooks', action: 'index' }
    end

    it 'returns an active link if the :order param is the given ordering' do
      link = Nokogiri::HTML(
        helper.link_to_sorted_cookbooks('Excellent', params, 'excellent')
      ).css('a').first

      expect(link['class']).to match(/active/)
    end

    it 'returns a non-active link if the :order param is not the given ordering' do
      link = Nokogiri::HTML(
        helper.link_to_sorted_cookbooks('Not Excellent', params, 'not_excellent')
      ).css('a').first

      expect(link['class'].to_s.split(' ')).to_not include('active')
    end

    it 'generates a link to the current page with the given ordering' do
      link = Nokogiri::HTML(
        helper.link_to_sorted_cookbooks('Not Excellent', params, 'not_excellent')
      ).css('a').first

      expect(URI(link['href']).path).
        to eql(url_for(controller: 'cookbooks', action: 'index'))
      expect(URI(link['href']).query).to include('order=not_excellent')
    end
  end

  describe '#foodcritic_info' do
    context 'when a cookbook version has passed foodcritic' do
      let(:passing_foodcritic) { "\nRun with Foodcritic Version 10.3.1 with tags ~FC031" }

      it 'does not include a new line at the beginning' do
        expect(helper.foodcritic_info(passing_foodcritic, false)).to_not match(/^\n/)
      end
      it 'does not include a <br />' do
        expect(helper.foodcritic_info(passing_foodcritic, false)).to_not include('<br />')
      end
    end

    context 'when a cookbook version has not passed foodcritic' do
      let(:failing_foodcritic) do
        "FC064: Ensure issues_url is set in metadata:\nRun with Foodcritic Version 10.3.1 with tags ~FC031"
      end

      it 'includes at least one <br />' do
        expect(helper.foodcritic_info(failing_foodcritic, true)) .to include('<br />')
      end
    end

    context 'when feedback is nil' do
      it 'does not include a new line at the beginning' do
        expect(helper.foodcritic_info(nil, true)) .to eq('No foodcritic feedback available')
      end
    end
  end
end
