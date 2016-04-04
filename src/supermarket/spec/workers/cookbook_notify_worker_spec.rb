require 'spec_helper'

describe CookbookNotifyWorker do
  let!(:system_email1) { create(:system_email, name: 'New cookbook version') }
  let!(:system_email2) { create(:system_email, name: 'Cookbook deprecated') }
  let!(:cookbook) { create(:cookbook) }

  it 'notifies each interested non-imported cookbook follower via email' do
    create_list(:cookbook_follower, 3, cookbook: cookbook)

    cookbook.cookbook_followers.last.user.tap do |disinterested_user|
      disinterested_user.email_preference_for('New cookbook version').destroy
    end

    cookbook.cookbook_followers.first.user.tap do |imported_user|
      imported_user.chef_account.update_attribute(:oauth_token, 'imported')
    end

    worker = CookbookNotifyWorker.new

    expect do
      Sidekiq::Testing.inline! do
        worker.perform(cookbook.latest_cookbook_version.id)
      end
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
