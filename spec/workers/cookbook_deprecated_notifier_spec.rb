require 'spec_helper'

describe CookbookDeprecatedNotifier do
  it 'sends emails to cookbook owner, collaborators and followers who want to receive emails' do
    cookbook = create(:cookbook)
    cookbook.deprecate(create(:cookbook))
    cookbook_collaborator = create(:cookbook_collaborator, cookbook: cookbook)
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
      cookbook_collaborator,
      cookbook_followers[0]
    ]

    expect do
      Sidekiq::Testing.inline! do
        CookbookDeprecatedNotifier.new.perform(cookbook.id)
      end
    end.to change(ActionMailer::Base.deliveries, :size).by(
      users_to_email.size
    )
  end
end
