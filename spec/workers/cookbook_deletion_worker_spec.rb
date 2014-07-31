require 'spec_helper'

describe CookbookDeletionWorker do
  let(:cookbook) { create(:cookbook) }
  let(:worker) { CookbookDeletionWorker.new }
  let(:sally) { create(:user, email_notifications: true) }
  let(:hank) { create(:user, email_notifications: false) }
  let(:jimmy) { create(:user, email_notifications: true) }
  let(:fanny) { create(:user, email_notifications: false) }

  before do
    create(:cookbook_collaborator, resourceable: cookbook, user: sally)
    create(:cookbook_collaborator, resourceable: cookbook, user: hank)
    create(:cookbook_follower, cookbook: cookbook, user: jimmy)
    create(:cookbook_follower, cookbook: cookbook, user: fanny)
  end

  it 'notifies each interested follower or collaborator via email' do
    expect do
      Sidekiq::Testing.inline! do
        worker.perform(cookbook.as_json)
      end
    end.to change(ActionMailer::Base.deliveries, :count).by(2)
  end

  it 'deletes all of the followers and collaborator relationships but not users' do
    expect(Collaborator.count).to eql(2)
    expect(CookbookFollower.count).to eql(2)

    Sidekiq::Testing.inline! do
      worker.perform(cookbook.as_json)
    end

    expect(Collaborator.count).to eql(0)
    expect(CookbookFollower.count).to eql(0)

    expect do
      sally.reload
      hank.reload
      jimmy.reload
      fanny.reload
    end.to_not raise_error
  end
end
