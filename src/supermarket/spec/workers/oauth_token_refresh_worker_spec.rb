require "spec_helper"
require "vcr_helper"

describe OauthTokenRefreshWorker do
  before do
    # NOTE: the purpose of these ENV variables is to facilitate happy-path VCR
    # cassette regeneration in the OauthTokenRefreshWorker. To re-record the
    # happy-path cassette(s) delete the existing cassette(s) and run this spec
    # with these ENV variables set to valid values. You can obtain valid values
    # by running the app locally, logging-in via OC-ID, and copying the tokens
    # set following authentication.
    #
    # So the general workflow, should you need to re-record the cassettes for
    # this spec, is:
    #
    # 1. Login to Supermarket through some valid oc-id server, somewhere.
    # 2. Open a Rails console on your Supermarket server and grab the
    #    oauth_token and oauth_refresh_token from the Account of the user that
    #    you just logged in as.
    # 3. Make a note of the CHEF_OAUTH2_APP_ID and CHEF_OAUTH2_SECRET ENV vars
    #    for the Supermarket server you used to login in step 1.
    # 3. Comment out the 2 ENV vars below and in their place, add 4 new ones
    #    that look like this:
    #
    #    ENV['VALID_OCID_OAUTH_TOKEN'] = 'oauth-token-you-just-retrieved'
    #    ENV['VALID_OCID_REFRESH_TOKEN'] = 'oauth-refresh-token-you-just-retrieved'
    #    ENV['CHEF_OAUTH2_APP_ID'] = 'oauth2-app-id-from-your-oc-id-server'
    #    ENV['CHEF_OAUTH2_SECRET'] = 'oauth2-secret-from-your-oc-id-server'
    #
    # 4. Change "record: :once" in the 2 specs below to "record: :all", re-run
    #    the specs and everything should pass.
    # 5. Once everything passes, change "record: :all" back to "record: :once",
    #    delete the 4 ENV vars you added, uncomment the 2 ENV vars below, and
    #    you're good to go.

    ENV["VALID_OCID_OAUTH_TOKEN"] ||= "oauth_token"
    ENV["VALID_OCID_REFRESH_TOKEN"] ||= "refresh_token"
  end

  it "updates the account's OAuth tokens" do
    account = create(:user).chef_account
    account.update!(
      oauth_token: ENV["VALID_OCID_OAUTH_TOKEN"],
      oauth_refresh_token: ENV["VALID_OCID_REFRESH_TOKEN"]
    )

    worker = OauthTokenRefreshWorker.new

    VCR.use_cassette("oauth_token_refresh_with_good_token", record: :new_episodes) do
      worker.perform(account.id)
    end

    account.reload

    expect(account.oauth_token).to_not eql(ENV["VALID_OCID_OAUTH_TOKEN"])
    expect(account.oauth_token).to_not be_blank

    expect(account.oauth_refresh_token).to_not eql(ENV["VALID_OCID_REFRESH_TOKEN"])
    expect(account.oauth_refresh_token).to_not be_blank

    expect(account.oauth_expires).to be_within(2.seconds).of(2.hours.from_now)
  end

  it "fails quietly if the account's refresh token is bad" do
    account = create(:user).chef_account
    account.update!(oauth_refresh_token: "dorfle")

    worker = OauthTokenRefreshWorker.new

    expect do
      VCR.use_cassette("oauth_token_refresh_with_bad_token", record: :new_episodes) do
        worker.perform(account.id)
      end
    end.to_not raise_error
  end

  it "fails silently if no such account exists" do
    worker = OauthTokenRefreshWorker.new

    expect do
      worker.perform(-1)
    end.to_not raise_error
  end

  context "dealing with custom chef oauth2 urls" do
    let!(:account) { create(:account) }

    let(:worker) { OauthTokenRefreshWorker.new }

    let(:strategy) { double("OmniAuth::Strategies::ChefOAuth2", client: "whatever") }

    let(:refreshed_token) do
      double("OmniAuth2::AccessToken",
             token: "Iamatoken",
             expires_at: Time.current + 1.hour,
             refresh_token: "AnotherToken")
    end

    let(:access_token) { double("OmniAuth2::AccessToken", refresh!: refreshed_token) }

    before do
      allow(OmniAuth::Strategies::ChefOAuth2).to receive(:new).and_return(strategy)
      allow(OAuth2::AccessToken).to receive(:new).and_return(access_token)
      allow(access_token).to receive(:refresh!).and_return(refreshed_token)
    end

    context "when the user has not defined a custom chef oauth2 url" do
      before do
        ENV["CHEF_OAUTH2_URL"] = nil
      end

      it "does not pass a url option" do
        expect(OmniAuth::Strategies::ChefOAuth2).to receive(:new).with(
          anything, # Rails.application
          client_id: anything,
          client_secret: anything,
          client_options: {} # Empty hash
        )

        VCR.use_cassette("oauth_token_refresh_with_good_token", record: :once) do
          worker.perform(account.id)
        end
      end
    end

    context "when the user has defined a custom chef oauth2 url" do
      let(:sample_custom_url) { "https://mycustomchefserver.io" }

      before do
        ENV["CHEF_OAUTH2_URL"] = sample_custom_url
      end

      it "passes the custom url" do
        expect(OmniAuth::Strategies::ChefOAuth2).to receive(:new).with(
          anything, # Rails.application
          client_id: anything,
          client_secret: anything,
          client_options: { site: sample_custom_url }
        ).and_return(strategy)

        VCR.use_cassette("oauth_token_refresh_with_good_token", record: :once) do
          worker.perform(account.id)
        end
      end
    end
  end
end
