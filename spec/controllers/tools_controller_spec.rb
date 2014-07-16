require 'spec_helper'

describe ToolsController do
  describe 'GET #index' do
    it 'responds with a 200' do
      get :index

      expect(response.status.to_i).to eql(200)
    end

    it 'assigns tools' do
      get :index

      expect(assigns(:tools)).to_not be_nil
    end

    it 'orders tools alphabetically' do
      ohai = create(:tool, name: 'ohai')
      supermarket = create(:tool, name: 'supermarket')

      get :index

      expect(assigns[:tools]).to match_array([ohai, supermarket])
    end

    it 'orders tools based on created at date' do
      supermarket = create(:tool, created_at: 1.day.ago)
      ohai = create(:tool, created_at: 10.days.ago)

      get :index, order: 'created_at'

      expect(assigns[:tools]).to match_array([supermarket, ohai])
    end
  end

  describe 'GET #new' do
    before do
      sign_in(create(:user))
    end

    it 'responds with a 200' do
      get :new

      expect(response.status.to_i).to eql(200)
    end

    it 'assigns a new tool' do
      get :new

      expect(assigns(:tool)).to_not be_nil
    end

    it 'assigns user' do
      get :new

      expect(assigns(:user)).to_not be_nil
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'creates a tool' do
      expect do
        post(
          :create,
          tool: {
            name: 'butter',
            type: 'Ohai Plugin',
            description: 'Great plugin.',
            source_url: 'http://example.com',
            instructions: 'Use with care'
          }
        )
      end.to change { Tool.count }.by(1)
    end

    it "redirects the user to the tool owner's profile tools tab" do
      post(
        :create,
        tool: {
          name: 'butter',
          type: 'Ohai Plugin',
          description: 'Great plugin.',
          source_url: 'http://example.com',
          instructions: 'Use with care'
        }
      )

      expect(response).to redirect_to(tools_user_path(user))
    end
  end
end
