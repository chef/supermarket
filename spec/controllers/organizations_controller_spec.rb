require 'spec_helper'

describe OrganizationsController do
  let!(:org1) { create(:organization) }
  let!(:org2) { create(:organization) }
  let!(:ccla_signature1) { create(:ccla_signature, organization: org1, company: 'International House of Pancakes') }
  let!(:ccla_signature2) { create(:ccla_signature, organization: org2, company: "Bob's House of Pancakes") }
  let!(:admin) { create(:user, roles: 'admin') }

  describe 'GET #index' do
    it 'succeeds' do
      get :index, format: :json
      expect(response).to be_success
    end

    it 'assigns organizations' do
      get :index, format: :json
      expect(assigns(:ccla_signatures)).to include(ccla_signature1, ccla_signature2)
    end

    it 'filters organizations when you pass in a search parameter' do
      get :index, q: 'international', format: :json
      expect(assigns(:ccla_signatures)).to include(ccla_signature1)
    end

    it 'excludes the current organization from search results' do
      get :index, exclude_id: org1.id, format: :json
      expect(assigns(:ccla_signatures).to_a).to_not include(ccla_signature1)
    end
  end

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
end
