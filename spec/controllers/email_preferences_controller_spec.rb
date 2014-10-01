require 'spec_helper'

describe EmailPreferencesController do
  let(:unsubscribe_request) { create(:unsubscribe_request) }

  describe 'GET /unsubscribe' do
    it 'should succeed' do
      get :unsubscribe, token: unsubscribe_request.token
      expect(response).to be_success
    end

    it 'should 404 if the token does not exist' do
      get :unsubscribe, token: 'haha'
      expect(response).to render_template('exceptions/404.html.erb')
    end

    it 'should unsubscribe the person from the email' do
      allow(UnsubscribeRequest).to receive(:find_by!) { unsubscribe_request }
      expect(unsubscribe_request).to receive(:make_it_so)
      get :unsubscribe, token: unsubscribe_request.token
    end
  end
end
