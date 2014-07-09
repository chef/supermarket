require 'spec_feature_helper'

describe 'a request to join a CCLA' do
  it 'can be accepted via email by CCLA admins', use_poltergeist: true do
    create(:ccla)
    sign_in(create(:user))
    sign_ccla('Acme')
    sign_out

    sign_in(create(:user))

    follow_relation 'contributors'
    follow_relation 'companies'
    follow_relation 'contributor-request'

    sign_out

    request = ActionMailer::Base.deliveries.first
    html = Nokogiri::HTML(request)
    url = html.css("a.accept").first.attribute('href').value
    path = URI(url).path

    visit path

    expect_to_see_success_message

    ActionMailer::Base.deliveries.clear
  end
end
