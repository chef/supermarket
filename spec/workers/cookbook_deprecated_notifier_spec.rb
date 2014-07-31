require 'spec_helper'

describe CookbookDeprecatedNotifier do
  it 'sends emails to cookbook owner, collaborators and followers who want to receive emails' do
    cookbook = create(:cookbook)
    cookbook.deprecate(create(:cookbook))
    cookbook_collaborator = create(:cookbook_collaborator, resourceable: cookbook)
    cookbook_followers = [
      create(:cookbook_follower, cookbook: cookbook),
      create(
        :cookbook_follower,
        cookbook: cookbook,
        user: create(:user, email_notifications: false)
      )
    ]

    users_to_email = [
      cookbook.owner,
      cookbook_collaborator.user,
      cookbook_followers[0].user
    ]

    Sidekiq::Testing.inline! do
      CookbookDeprecatedNotifier.new.perform(cookbook.id)
    end

    recipients = ActionMailer::Base.deliveries.map(&:to).flatten.sort

    expect(recipients).to eql(users_to_email.map(&:email).sort)
  end
end
