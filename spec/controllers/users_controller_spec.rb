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
  end
end
