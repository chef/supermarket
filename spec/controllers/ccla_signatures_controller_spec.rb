require 'spec_helper'

describe CclaSignaturesController do
  describe 'admin can view ccla' do
    let(:admin) { create(:user, roles: 'admin') }
    let(:ccla_signature) { create(:ccla_signature) }
    before { sign_in admin }
    before { get :show, id: ccla_signature.id }

    it { should respond_with(200) }

    it 'assigns @ccla_signature' do
      expect(assigns(:ccla_signature)).to eq(ccla_signature)
    end
  end

  describe 'user cannot view ccla that they do not belong to' do
    let(:user) { create(:user) }
    let(:ccla_signature) { create(:ccla_signature) }
    before { sign_in user }
    before { get :show, id: ccla_signature.id }

    it { should respond_with(404) }
  end

  describe 'user can view ccla that they belong to' do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organizations: [organization]) }
    let(:ccla_signature) { create(:ccla_signature, organization: organization) }
    before { sign_in user }
    before { get :show, id: ccla_signature.id }

    it { should respond_with(200) }
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:payload) { attributes_for(:ccla_signature, user_id: user.id) }
    before { sign_in user }

    it 'creates a ccla signature for the current user' do
      expect {
        post :create, ccla_signature: payload
      }.to change(user.ccla_signatures, :count).by(1)
    end

    it 'creates an organization' do
      expect {
        post :create, ccla_signature: payload
      }.to change(Organization, :count).by(1)
    end

    it 'adds the current user to the newly-created organization' do
      expect {
        post :create, ccla_signature: payload
      }.to change(user.organizations, :count).by(1)
    end
  end
end
