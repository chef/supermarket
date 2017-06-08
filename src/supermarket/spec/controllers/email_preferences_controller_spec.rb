require 'spec_helper'

describe EmailPreferencesController do
  let(:email_preference) { create(:email_preference) }

  describe 'GET /unsubscribe/:token' do
    it 'should succeed' do
      get :unsubscribe, params: { token: email_preference }
      expect(response).to be_success
    end

    it 'should 404 if the token does not exist' do
      get :unsubscribe, params: { token: 'haha' }
      expect(response.status.to_i).to eql(404)
    end

    it 'should unsubscribe the person from the email' do
      allow(EmailPreference).to receive(:find_by!) { email_preference }
      expect(email_preference).to receive(:destroy)
      get :unsubscribe, params: { token: email_preference }
    end
  end
end
