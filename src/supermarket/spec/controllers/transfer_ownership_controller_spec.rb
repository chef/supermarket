require "spec_helper"

describe TransferOwnershipController do
  describe "PUT #transfer" do
    let(:cookbook) { create(:cookbook) }
    let(:new_owner) { create(:user) }

    before do
      cookbook_collection = double("cookbook_collection", first!: cookbook)
      allow(Cookbook).to receive(:with_name) { cookbook_collection }
    end

    shared_examples "admin_or_owner" do
      before { sign_in(user) }

      it "attempts to change the cookbooks owner" do
        expect(cookbook).to receive(:transfer_ownership).with(
          user,
          new_owner,
          false
        ) { "cookbook.ownership_transfer.done" }
        put :transfer, params: { id: cookbook, cookbook: { user_id: new_owner.id, add_owner_as_collaborator: "0" } }
      end

      it "attempts to change the cookbooks owner and save the current owner as a contributor" do
        expect(cookbook).to receive(:transfer_ownership).with(
          user,
          new_owner,
          true
        ) { "cookbook.ownership_transfer.done" }
        put :transfer, params: { id: cookbook, cookbook: { user_id: new_owner.id, add_owner_as_collaborator: "1" } }
      end

      it "redirects back to the cookbook" do
        put :transfer, params: { id: cookbook, cookbook: { user_id: new_owner.id } }
        expect(response).to redirect_to(assigns[:cookbook])
      end
    end

    context "the current user is an admin" do
      let(:user) { create(:admin) }
      it_behaves_like "admin_or_owner"
    end

    context "the current user is the cookbook owner" do
      let(:user) { cookbook.owner }
      it_behaves_like "admin_or_owner"
    end

    context "the current user is not an admin nor an owner of the cookbook" do
      before { sign_in(create(:user)) }

      it "returns a 404" do
        put :transfer, params: { id: cookbook, cookbook: { user_id: new_owner.id } }
        expect(response.status.to_i).to eql(404)
      end
    end
  end

  context "transfer requests" do
    let(:transfer_request) { create(:ownership_transfer_request) }

    shared_examples "a transfer request" do
      it "redirects back to the cookbook" do
        post :accept, params: { token: transfer_request }
        expect(response).to redirect_to(assigns[:transfer_request].cookbook)
      end

      it "finds transfer requests based on token" do
        post :accept, params: { token: transfer_request }
        expect(assigns[:transfer_request]).to eql(transfer_request)
      end

      it "returns a 404 if the transfer request given has already been updated" do
        transfer_request.update(accepted: true)
        post :accept, params: { token: transfer_request }
        expect(response.status.to_i).to eql(404)
      end
    end

    describe "GET #accept" do
      it "attempts to accept the transfer request" do
        allow(OwnershipTransferRequest).to receive(:find_by!) { transfer_request }
        expect(transfer_request.accepted).to be_nil
        expect(transfer_request).to receive(:accept!)
        get :accept, params: { token: transfer_request }
      end

      it "re-evaluates collaborator rating" do
        allow(OwnershipTransferRequest).to receive(:find_by!) { transfer_request }
        expect(transfer_request.accepted).to be_nil
        expect(transfer_request).to receive(:accept!)
        expect do
          get :accept, params: { token: transfer_request }
        end.to change(FieriNotifyWorker.jobs, :size).by(1)
      end

      it_behaves_like "a transfer request"
    end

    describe "GET #decline" do
      it "attempts to decline the transfer request" do
        allow(OwnershipTransferRequest).to receive(:find_by!) { transfer_request }
        expect(transfer_request.accepted).to be_nil
        expect(transfer_request).to receive(:decline!)
        get :decline, params: { token: transfer_request }
      end

      it_behaves_like "a transfer request"
    end
  end
end
