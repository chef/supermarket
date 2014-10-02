require 'spec_helper'

describe CookbookDeletionWorker do
  let!(:system_email1) { create(:system_email, name: 'Cookbook deleted') }
  let!(:system_email2) { create(:system_email, name: 'Cookbook deprecated') }
  let!(:cookbook) { create(:cookbook) }
  let!(:worker) { CookbookDeletionWorker.new }
  let!(:sally) { create(:user) }
  let!(:hank) { create(:user) }
  let!(:jimmy) { create(:user) }
  let!(:fanny) { create(:user) }

  before do
    [hank, fanny].each do |person|
      person.email_preference_for('Cookbook deleted').destroy
    end

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
