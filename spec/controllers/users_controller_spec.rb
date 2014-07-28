require 'spec_helper'

describe UsersController do
  let(:user) { create(:user) }

  describe 'GET #show' do
    it 'assigns a user' do
      get :show, id: user.username

      expect(assigns[:user]).to eql(user)
    end

    it 'assigns cookbooks' do
      get :show, id: user.username

      expect(assigns[:cookbooks]).to_not be_nil
    end

    it 'assigns a specific context of cookbooks given the tab parameter' do
      followed_cookbook = create(:cookbook_follower, user: user).cookbook

      get :show, id: user.username, tab: 'follows'

      expect(assigns[:cookbooks]).to include(followed_cookbook)
    end

    it '404s when when a user somehow has a Chef account but does not exist' do
      username = user.username

      User.where(id: user.id).delete_all

      get :show, id: user.username, user_tab_string: 'activity'

      expect(response).to render_template('exceptions/404.html.erb')
    end
  end

  describe 'GET #tools' do
    it 'assigns a user' do
      get :tools, id: user.username

      expect(assigns[:user]).to eql(user)
    end

    it "assigns a user's tools" do
      create(:tool, owner: user)

      get :tools, id: user.username

      expect(assigns[:tools].to_a).to eql(user.tools.to_a)
    end
  end

  describe 'GET #followed_cookbook_activity' do
    it 'assigns a user' do
      get :tools, id: user.username

      expect(assigns[:user]).to eql(user)
    end

    it "assigns a user's followed cookbook activity" do
      get :followed_cookbook_activity, id: user.username

      expect(assigns[:followed_cookbook_activity]).to_not be_nil
    end
  end

  describe 'PUT #make_admin' do
    let(:user) { create(:user) }

    context 'the current user is an admin' do
      before { sign_in(create(:admin)) }

      it 'adds the admin role to a user' do
        put :make_admin, id: user
        user.reload
        expect(user.roles).to include('admin')
      end

      it 'redirects back to a user' do
        put :make_admin, id: user
        expect(response).to redirect_to(assigns[:user])
      end
    end

    context 'the current user is not an admin' do
      before { sign_in(create(:user)) }

      it 'renders 404' do
        put :make_admin, id: user
        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe 'DELETE #revoke_admin' do
    let(:user) { create(:admin) }

    context 'the current user is an admin' do
      before { sign_in(create(:admin)) }

      it 'removes the admin role to a user' do
        delete :revoke_admin, id: user
        user.reload
        expect(user.roles).to_not include('admin')
      end

      it 'redirects back to a user' do
        delete :revoke_admin, id: user
        expect(response).to redirect_to(assigns[:user])
      end
    end

    context 'the current user is not an admin' do
      before { sign_in(create(:user)) }

      it 'renders 404' do
        delete :revoke_admin, id: user
        expect(response.status.to_i).to eql(404)
      end
    end
  end
end
