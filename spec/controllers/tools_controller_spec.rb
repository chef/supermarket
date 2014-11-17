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

    it 'only displays tools of a certain type with a type parameter present' do
      knife_plugin = create(:tool, type: 'knife_plugin')
      ohai_plugin = create(:tool, type: 'ohai_plugin')

      get :index, type: 'knife_plugin'

      expect(assigns(:tools)).to include(knife_plugin)
      expect(assigns(:tools)).to_not include(ohai_plugin)
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

    it 'only returns @tools that match the query parameter' do
      ohai = create(:tool, name: 'ohai')
      supermarket = create(:tool, name: 'supermarket')

      get :index, q: 'supermarket'

      expect(assigns[:tools]).to include(supermarket)
      expect(assigns[:tools]).to_not include(ohai)
    end

    it 'sets the default search context as tools' do
      get :index

      expect(assigns[:search][:name]).to eql('Tools')
      expect(assigns[:search][:path]).to eql(tools_path)
    end
  end

  describe 'GET #show' do
    context 'when the tool exists' do
      let(:tool) { create(:tool) }

      before { get :show, id: tool }

      it 'responds with a 200' do
        expect(response).to be_success
      end

      it 'assigns a new tool' do
        expect(assigns(:tool)).to_not be_nil
      end

      it 'assigns other tools' do
        expect(assigns(:other_tools)).to_not be_nil
      end
    end

    context 'when the tool does not exist' do
      it '404s' do
        get :show, id: 'dorfle'

        expect(response.status.to_i).to eql(404)
      end
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

    it 'assigns user' do
      post :create, tool: { name: 'butter' }

      expect(assigns(:user)).to_not be_nil
    end

    it 'creates a tool' do
      expect do
        post(
          :create,
          tool: {
            name: 'butter',
            slug: 'butter',
            type: 'ohai_plugin',
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
          slug: 'butter',
          type: 'ohai_plugin',
          description: 'Great plugin.',
          source_url: 'http://example.com',
          instructions: 'Use with care'
        }
      )

      expect(response).to redirect_to(tools_user_path(user))
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }
    let(:tool) { create(:tool, owner: user) }

    before do
      sign_in(user)
    end

    it 'responds with a 200' do
      get :edit, id: tool

      expect(response.status.to_i).to eql(200)
    end

    it 'assigns tool' do
      get :edit, id: tool

      expect(assigns(:tool)).to_not be_nil
    end

    it 'assigns user' do
      get :edit, id: tool

      expect(assigns(:user)).to_not be_nil
    end

    it '404s if the user is not authorized to edit the tool' do
      sign_in(create(:user))

      get :edit, id: tool

      expect(response.status.to_i).to eql(404)
    end
  end

  describe 'POST #adoption' do
    let(:user) { create(:user) }
    let(:tool) { create(:tool, name: 'haha') }
    before { sign_in user }

    it 'sends an adoption email' do
      Sidekiq::Testing.inline! do
        expect { post :adoption, id: tool }
        .to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    it 'redirects to the @tool' do
      post :adoption, id: tool
      expect(response).to redirect_to(assigns[:tool])
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:tool) { create(:tool, name: 'butter', owner: user) }

    before do
      sign_in(user)
    end

    it 'assigns user' do
      patch :update, id: tool, tool: { name: 'margarine' }

      expect(assigns(:user)).to_not be_nil
    end

    it 'updates a tool' do
      patch :update, id: tool, tool: { name: 'margarine', up_for_adoption: true }

      tool.reload
      expect(tool.name).to eql('margarine')
      expect(tool.up_for_adoption).to eql(true)
    end

    it 'redirects the user to the tool' do
      patch :update, id: tool, tool: { name: 'margarine' }

      expect(response).to redirect_to(tool_path(tool))
    end

    it 'renders the edit form when the tool is invalid' do
      patch :update, id: tool, tool: { name: '' }

      expect(response).to render_template('tools/edit')
    end

    it '404s if the user is not authorized to update the tool' do
      sign_in(create(:user))

      patch :update, id: tool, tool: { name: 'margarine' }

      expect(response.status.to_i).to eql(404)
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }
    let!(:tool) { create(:tool, name: 'butter', owner: user) }

    before do
      sign_in(user)
    end

    it 'deletes a tool' do
      expect do
        delete :destroy, id: tool
      end.to change { Tool.count }.by(-1)
    end

    it "redirects the user to the tool owner's profile tools tab" do
      delete :destroy, id: tool
      expect(response).to redirect_to(tools_user_path(user))
    end

    it '404s if the user is not authorized to delete the tool' do
      sign_in(create(:user))

      delete :destroy, id: tool

      expect(response.status.to_i).to eql(404)
    end
  end

  describe 'GET #directory' do
    before { get :directory }

    it 'assigns @recently_added_tools' do
      expect(assigns[:recently_added_tools]).to_not be_nil
    end
  end
end
