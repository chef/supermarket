require 'spec_helper'

describe PagesController do
  let(:user) { create(:user) }

  describe 'GET #welcome' do
    context 'user is not signed in' do
      it 'responds with a 200' do
        get :welcome

        expect(response.status.to_i).to eql(200)
      end

      it 'sends recently updated cookbook count to the view' do
        get :welcome

        expect(assigns[:recently_updated_count]).to_not be_nil
      end

      it 'sends cookbook count to the view' do
        get :welcome

        expect(assigns[:cookbook_count]).to_not be_nil
      end

      it 'sends download count to the view' do
        get :welcome

        expect(assigns[:download_count]).to_not be_nil
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
    end

    context 'user is not signed in' do
      it 'redirects to the welcome page' do
        get :dashboard

        expect(response).to redirect_to(sign_in_path)
      end
    end
  end
end
