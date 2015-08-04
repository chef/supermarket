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

    it 'sets the default search context as tools' do
      get :tools, id: user.username

      expect(assigns[:search][:name]).to eql('Tools')
      expect(assigns[:search][:path]).to eql(tools_path)
    end
  end

  describe 'GET #groups' do
    it 'assigns a user' do
      get :groups, id: user.username
      expect(assigns[:user]).to eql(user)
    end

    context 'finding a user\'s groups' do
      let!(:group_1) { create(:group) }
      let!(:group_2) { create(:group) }

      before do
        user.memberships << group_1

        expect(user.memberships).to include(group_1)
        expect(user.memberships).to_not include(group_2)
      end

      it 'includes all groups user is a member of' do
        get :groups, id: user.username
        expect(assigns(:groups)).to include(group_1)
      end

      it 'does not include groups user is NOT a member of' do
        get :groups, id: user.username
        expect(assigns(:groups)).to_not include(group_2)
      end
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
