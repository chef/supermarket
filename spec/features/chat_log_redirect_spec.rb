require 'spec_feature_helper'

describe 'accessing the chat channels list' do
  it 'redirects to the botbot dashboard', use_poltergeist: true do
    visit root_url
    visit '/chat'

    botbot_dashboard_url = 'https://botbot.me/dashboard/'
    expect(page.current_url).to eql(botbot_dashboard_url)
  end
end

describe 'accessing specific chat channels' do
  it 'redirects to the botbot channel if the date is after August 8th, 2013', use_poltergeist: true do
    visit root_url
    visit '/chat/chef/2014-01-24'

    botbot_chef_url = 'https://botbot.me/freenode/chef/2014-01-24/'
    expect(page.current_url).to eql(botbot_chef_url)
  end

  it 'redirects to the botbot channel if the date is not specified', use_poltergeist: true do
    visit root_url
    visit '/chat/chef'

    botbot_chef_url = 'https://botbot.me/freenode/chef/'
    expect(page.current_url).to eql(botbot_chef_url)
  end
end
