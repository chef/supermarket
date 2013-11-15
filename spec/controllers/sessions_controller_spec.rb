require 'spec_helper'

describe SessionsController do
  describe 'GET #new' do
    before { get :new }

    it { should respond_with(200) }
    it { should render_template('new') }

    context 'when a user is already signed in' do
      before { subject.stub(:current_user).and_return(build(:user)) }
      before { get :new }

      it { should redirect_to(root_path) }
    end
  end

  describe 'POST #create' do
    let(:auth_hash) { OmniAuth.config.mock_auth[:default] }

    before do
      User.stub(:from_oauth).and_return(double(id: 1, name: 'John Doe'))
      request.env['omniauth.auth'] = auth_hash
    end

    it 'loads or creates the user from the OAuth hash' do
      expect(User).to receive(:from_oauth).with(auth_hash, nil)
      post :create, provider: 'default'
    end

    it 'sets the session' do
      post :create, provider: 'default'
      expect(session[:user_id]).to eq(1)
    end

    it 'redirects to the root path' do
      post :create, provider: 'default'
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET #failure' do
    before { get :failure }

    it { should respond_with(200) }
    it { should render_template('failure') }
  end
end
