require 'spec_helper'

describe CookbookDeprecatedNotifier do
  let!(:system_email1) { create(:system_email, name: 'Cookbook deleted') }
  let!(:system_email2) { create(:system_email, name: 'Cookbook deprecated') }

  it 'sends emails to cookbook owner, collaborators and followers who want to receive emails' do
    disinterested_user = create(:user)
    disinterested_user.email_preference_for('Cookbook deprecated').destroy
    cookbook = create(:cookbook)
    cookbook.deprecate(create(:cookbook).name)
    cookbook_collaborator = create(:cookbook_collaborator, resourceable: cookbook)
    cookbook_followers = [
      create(:cookbook_follower, cookbook: cookbook),
      create(
        :cookbook_follower,
        cookbook: cookbook,
        user: disinterested_user
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
