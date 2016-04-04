require 'spec_helper'

describe OrganizationsController do
  let!(:org1) { create(:organization) }
  let!(:org2) { create(:organization) }
  let!(:admin) { create(:user, roles: 'admin') }

  describe 'GET #show' do
    before do
      sign_in admin
      get :show, id: org1
    end

    it 'assigns the organization' do
      expect(assigns(:organization)).to eql(org1)
    end

    it 'succeeds' do
      expect(response).to be_success
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in admin }

    it 'assigns the organization' do
      delete :destroy, id: org1
      expect(assigns(:organization)).to eql(org1)
    end

    it 'deletes the organization' do
      expect do
        delete :destroy, id: org1
      end.to change(Organization, :count).by(-1)
    end

    it 'redirects to the CCLA signatures page' do
      delete :destroy, id: org1
      expect(response).to redirect_to(ccla_signatures_path)
    end

    it 'contains a helpful flash message' do
      delete :destroy, id: org1
      expect(request.flash[:notice]).to_not be_nil
    end
  end

  describe 'PUT #combine' do
    before { sign_in admin }

    it 'assigns the organization' do
      put :combine, id: org1, organization: { combine_with_id: org2 }
      expect(assigns(:organization)).to eql(org1)
    end

    it 'deletes the second organization' do
      expect do
        put :combine, id: org1, organization: { combine_with_id: org2 }
      end.to change(Organization, :count).by(-1)
    end

    it 'combines the two organizations together' do
      expect(Organization).to receive(:find).with(org1.id.to_s) { org1 }
      expect(Organization).to receive(:find).with(org2.id.to_s) { org2 }
      expect(org1).to receive(:combine!).with(org2)
      put :combine, id: org1, organization: { combine_with_id: org2 }
    end

    it 'redirects to the CCLA signatures page' do
      put :combine, id: org1, organization: { combine_with_id: org2 }
      expect(response).to redirect_to(ccla_signatures_path)
    end

    it 'contains a helpful flash message' do
      put :combine, id: org1, organization: { combine_with_id: org2 }
      expect(request.flash[:notice]).to_not be_nil
    end
  end

  describe 'GET #requests_to_join' do
    before do
      sign_in admin
      get :requests_to_join, id: org1
    end

    it 'assigns the organization' do
      expect(assigns(:organization)).to eql(org1)
    end

    it 'assigns the pending requests to join the organization' do
      expect(assigns(:pending_requests)).to_not be_nil
    end

    it 'succeeds' do
      expect(response).to be_success
    end
  end
end
