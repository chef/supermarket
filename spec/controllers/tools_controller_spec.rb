require 'spec_helper'

describe ToolsController do
  describe 'GET #new' do
    context 'when signed in' do
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
    end

    context 'when not signed in' do
    end
  end
end
