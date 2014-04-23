require 'spec_helper'

describe CookbookNotifyWorker do
  let(:cookbook) { create(:cookbook) }

  it 'notifies each interested cookbook follower via email' do
    create_list(:cookbook_follower, 2, cookbook: cookbook)

    cookbook.cookbook_followers.last.user.tap do |disinterested_user|
      disinterested_user.update_attribute(:email_notifications, false)
    end

    worker = CookbookNotifyWorker.new

    expect do
      Sidekiq::Testing.inline! do
        worker.perform(cookbook.id)
      end
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
