require 'spec_helper'

describe SessionsController do
  describe 'POST #create' do
    let(:auth_hash) { OmniAuth.config.mock_auth[:chef_oauth2] }

    before do
      allow(User).to receive(:find_or_create_from_chef_oauth).and_return(double(id: 1, name: 'John Doe'))
      request.env['omniauth.auth'] = auth_hash
    end

    it 'loads or creates the user from the OAuth hash' do
      expect(User).to receive(:find_or_create_from_chef_oauth).with(auth_hash)
      post :create, params: { provider: 'chef_oauth2' }
    end

    it 'sets the session' do
      post :create, params: { provider: 'chef_oauth2' }
      expect(session[:user_id]).to eq(1)
    end

    it 'redirects to the root path' do
      post :create, params: { provider: 'chef_oauth2' }
      expect(response).to redirect_to(root_path)
    end

    it 'notifies the user they have signed in' do
      post :create, params: { provider: 'chef_oauth2' }
      expect(flash[:notice]).
        to eql(I18n.t('user.signed_in', name: 'John Doe'))
    end
  end

  describe 'DELETE #destroy' do
    it 'resets the session' do
      delete :destroy
      expect(session[:user_id]).to be_blank
    end

    it 'notifies the user they have signed out' do
      delete :destroy
      expect(flash[:notice]).
        to eql(I18n.t('user.signed_out'))
    end
  end

  describe 'GET #failure' do
    before { get :failure }

    it { should respond_with(200) }
    it { should render_template('failure') }
  end
end
