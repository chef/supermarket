require 'spec_helper'

describe PagesController do
  let(:user) { create(:user) }

  describe 'GET #welcome' do
    context 'user is not signed in' do
      it 'responds with a 200' do
        get :welcome

        expect(response.status.to_i).to eql(200)
      end

      it 'sends cookbook count to the view' do
        get :welcome

        expect(assigns[:cookbook_count]).to_not be_nil
      end

      it 'sends user count to the view' do
        get :welcome

        expect(assigns[:user_count]).to_not be_nil
      end
    end

    context 'user is signed in' do
      before { sign_in user }

      it 'redirects the user to the dashboard' do
        get :welcome

        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe 'GET #dashboard' do
    context 'user is signed in' do
      before { sign_in user }

      it 'assigns cookbooks' do
        get :dashboard

        expect(assigns[:cookbooks]).to_not be_nil
      end

      it 'assigns collaborated cookbooks' do
        get :dashboard

        expect(assigns[:collaborated_cookbooks]).to_not be_nil
      end

      it 'assigns tools' do
        get :dashboard

        expect(assigns[:tools]).to_not be_nil
      end

      it '404s when requested with JSON' do
        # NOTE: this is a specific test for a more general scenario:
        # Supermarket fields a request to some action which only has an HTML
        # template. We define the correct behavior to be 404 Not Found.
        get :dashboard, format: :json

        expect(response.status.to_i).to eql(404)
      end
    end

    context 'user is not signed in' do
      it 'redirects to the welcome page' do
        get :dashboard

        expect(response).to redirect_to(sign_in_path)
      end
    end
  end
end
