require 'spec_helper'

describe Api::UsersController do
  describe 'GET #index' do
    before { get :index }

    it { should respond_with(200) }
    it { should render_template('index') }

    it 'assigns @users' do
      users = create_list(:user, 2)
      expect(assigns(:users)).to eq(users)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }
    before { get :show, id: user.id }

    it { should respond_with(200) }
    it { should render_template('show') }

    it 'assigns @user' do
      expect(assigns(:user)).to eq(user)
    end
  end
end
