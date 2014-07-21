require 'spec_feature_helper'

describe 'a request to join a CCLA' do
  #
  # Wait about five seconds for a condition to be true
  #
  def wait_for(&condition)
    ticks = 0

    loop do
      sleep 1
      ticks += 1

      break if ticks > 5
      break if condition.call
    end
  end

  it 'can be accepted via email by CCLA admins', use_poltergeist: true do
    admin_user = create(:user)
    create(:ccla)
    sign_in(admin_user)
    sign_ccla('Acme')
    sign_out

    sign_in(create(:user))

    follow_relation 'contributors'
    follow_relation 'companies'
    follow_relation 'company-contributors'

    Sidekiq::Testing.inline! do
      follow_relation 'contributor-request'

      wait_for { relations('contributor-request').empty? }
    end

    sign_out

    sign_in(admin_user)

    message = ActionMailer::Base.deliveries.first.parts.find do |part|
      part.content_type.include?('text/html')
    end

    html = Nokogiri::HTML(message.body.to_s)

    url = html.css('a.accept').first.attribute('href').value
    path = URI(url).path

    visit path

    expect_to_see_success_message

    ActionMailer::Base.deliveries.clear
  end
end
