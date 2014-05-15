require 'spec_helper'
require 'vcr_helper'

describe OauthTokenRefreshWorker do
  before do
    # NOTE: the purpose of these ENV variables is to facilitate happy-path VCR
    # cassette regeneration in the OauthTokenRefreshWorker. To re-record the
    # happy-path cassette(s) delete the existing cassette(s) and run this spec
    # with these ENV variables set to valid values. You can obtain valid values
    # by running the app locally, logging-in via OC-ID, and copying the tokens
    # set following authentication
    ENV['VALID_OCID_OAUTH_TOKEN'] ||= 'oauth_token'
    ENV['VALID_OCID_REFRESH_TOKEN'] ||= 'refresh_token'
  end

  it "updates the account's OAuth tokens" do
    account = create(:user).chef_account
    account.update_attributes!(
      oauth_token: ENV['VALID_OCID_OAUTH_TOKEN'],
      oauth_refresh_token: ENV['VALID_OCID_REFRESH_TOKEN']
    )

    worker = OauthTokenRefreshWorker.new

    VCR.use_cassette('oauth_token_refresh_with_good_token', record: :once) do
      worker.perform(account.id)
    end

    account.reload

    expect(account.oauth_token).to_not eql(ENV['VALID_OCID_OAUTH_TOKEN'])
    expect(account.oauth_token).to_not be_blank

    expect(account.oauth_refresh_token).to_not eql(ENV['VALID_OCID_REFRESH_TOKEN'])
    expect(account.oauth_refresh_token).to_not be_blank

    expect(account.oauth_expires).to be_within(2.seconds).of(2.hours.from_now)
  end

  it "fails quietly if the account's refresh token is bad" do
    account = create(:user).chef_account
    account.update_attributes!(oauth_refresh_token: 'dorfle')

    worker = OauthTokenRefreshWorker.new

    expect do
      VCR.use_cassette('oauth_token_refresh_with_bad_token', record: :once) do
        worker.perform(account.id)
      end
    end.to_not raise_error
  end

  it 'fails silently if no such account exists' do
    worker = OauthTokenRefreshWorker.new

    expect do
      worker.perform(-1)
    end.to_not raise_error
  end
end
