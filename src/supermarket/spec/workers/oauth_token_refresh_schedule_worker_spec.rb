require 'spec_helper'

describe OauthTokenRefreshScheduleWorker do
  let(:worker) { OauthTokenRefreshScheduleWorker.new }

  it 'refreshes only tokens which expire soon' do
    expiring_users = FactoryBot.create_list(:user, 3)

    expect(Account)
      .to receive(:tokens_expiring_soon)
      .and_return(expiring_users)

    expect do
      worker.perform
    end.to change(OauthTokenRefreshWorker.jobs, :size).by(3)
  end
end
