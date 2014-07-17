require 'spec_helper'

describe ContributorRequestNotifier do
  it 'sends emails to each admin in the organization' do
    admin_users = 2.times.map { create(:user) }
    organization = create(:organization)
    organization.contributors.create!(user: create(:user))
    admin_users.each { |user| organization.admins.create!(user: user) }

    contributor_request = create(
      :contributor_request,
      organization: organization
    )

    expect do
      Sidekiq::Testing.inline! do
        ContributorRequestNotifier.new.perform(contributor_request.id)
      end
    end.to change(ActionMailer::Base.deliveries, :size).by(admin_users.size)
  end
end
