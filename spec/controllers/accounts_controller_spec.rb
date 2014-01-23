require 'spec_helper'

describe AccountsController do
  describe 'POST #create' do
    let(:user) { create(:user) }
    before { sign_in user }

    it 'creates a new account for a user' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]

      expect do
        post :create, provider: 'github'
      end.to change(user.accounts, :count).by(1)
    end
  end
end
