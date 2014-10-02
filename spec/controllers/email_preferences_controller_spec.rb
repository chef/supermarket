require 'spec_helper'

describe EmailPreferencesController do
  let(:email_preference) { create(:email_preference) }

  describe 'GET /unsubscribe/:token' do
    it 'should succeed' do
      get :unsubscribe, token: email_preference
      expect(response).to be_success
    end

    it 'should 404 if the token does not exist' do
      get :unsubscribe, token: 'haha'
      expect(response).to render_template('exceptions/404.html.erb')
    end

    it 'should unsubscribe the person from the email' do
      allow(EmailPreference).to receive(:find_by!) { email_preference }
      expect(email_preference).to receive(:destroy)
      get :unsubscribe, token: email_preference
    end
  end
end
