require 'spec_helper'

describe OauthTokenRefreshScheduleWorker do
  context 'on the first run' do
    it 'refreshes only tokens which expire 20-25 minutes from now' do
      last_run = -1 # Sidetiq uses -1 to denote the first run
      now = Time.now

      [19.9, 20, 22, 25, 26.1].each do |expiry|
        create(:user).tap do |user|
          user.chef_account.update_attributes!(
            oauth_expires: now + expiry.minutes
          )
        end
      end

      worker = OauthTokenRefreshScheduleWorker.new

      expect do
        worker.perform(last_run, now.to_f)
      end.to change(OauthTokenRefreshWorker.jobs, :size).by(3)
    end
  end

  context 'on subsequent runs' do
    it 'refreshes only tokens which expire 20-25 minutes from now' do
      last_run = 5.minutes.ago
      now = Time.now

      [19.9, 20, 22, 25, 26.1].each do |expiry|
        create(:user).tap do |user|
          user.chef_account.update_attributes!(
            oauth_expires: now + expiry.minutes
          )
        end
      end

      worker = OauthTokenRefreshScheduleWorker.new

      expect do
        worker.perform(last_run, now.to_f)
      end.to change(OauthTokenRefreshWorker.jobs, :size).by(3)
    end
  end
end
