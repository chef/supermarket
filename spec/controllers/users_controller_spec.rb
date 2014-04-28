require 'spec_helper'

describe UsersController do
  let(:user) { create(:user) }

  describe 'GET #show' do
    it 'assigns a user' do
      get :show, id: user.username

      expect(assigns[:user]).to eql(user)
    end
  end
end
