require "spec_helper"

describe AccountsController do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "POST #create" do
    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
    end

    it "creates a new account for a user" do
      expect do
        post :create, params: { provider: "github" }
      end.to change(user.accounts, :count).by(1)
    end

    it "redirects to the user profile on success by default" do
      post :create, params: { provider: "github" }

      expect(response).to redirect_to(edit_profile_path)
    end

    it "redirects to the stored location for the user on success if set" do
      controller.store_location!(cookbooks_path)

      post :create, params: { provider: "github" }

      expect(response).to redirect_to(cookbooks_path)
    end
  end

  describe "DELETE #destroy" do
    let!(:account) { create(:account, user: user) }

    it "destroys an account for a user" do
      request.env["HTTP_REFERER"] = "http://example.com/back"

      expect { delete :destroy, params: { id: account.id, user_id: user.id } }
        .to change(user.accounts, :count).by(-1)
    end
  end
end
