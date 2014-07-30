require 'spec_feature_helper'

describe 'accessing the chat channels list' do
  it 'redirects to the botbot dashboard', use_poltergeist: true do
    visit '/chat'

    botbot_dashboard_url = 'https://botbot.me/dashboard/'
    expect(page.current_url).to eql(botbot_dashboard_url)
  end
end
