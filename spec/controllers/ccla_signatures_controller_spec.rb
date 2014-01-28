require 'spec_helper'

describe CclaSignaturesController do
  describe 'GET #show' do

    context 'when viewing a signature as an admin' do
      let(:admin) { create(:user, roles: 'admin') }
      let(:ccla_signature) { create(:ccla_signature) }
      before { sign_in admin }
      before { get :show, id: ccla_signature.id }

      it { should respond_with(200) }

      it 'assigns @ccla_signature' do
        expect(assigns(:ccla_signature)).to eq(ccla_signature)
      end
    end

    context "when viewing another user's signature as a non-admin" do
      let(:user) { create(:user) }
      let(:ccla_signature) { create(:ccla_signature) }
      before { sign_in user }
      before { get :show, id: ccla_signature.id }

      it { should respond_with(404) }
    end

    context "when viewing a CCLA that the user signed" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organizations: [organization]) }
      let(:ccla_signature) { create(:ccla_signature, organization: organization) }
      before { sign_in user }
      before { get :show, id: ccla_signature.id }

      it { should respond_with(200) }
    end

  end

  describe 'GET #new' do

    let(:user) { create(:user) }

    context 'when the user has no linked GitHub accounts' do

      before do
        user.accounts.clear
        sign_in user

        get :new
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(user)
      end

      it 'prompts the user to link their GitHub account' do
        expect(flash[:notice]).
          to eql(I18n.t('ccla_signature.requires_linked_github'))
      end

      it 'stores the signature page as the "stored location" for the user' do
        expect(controller.stored_location_for(user)).
          to eql(new_ccla_signature_path)
      end

    end

    context 'when the user has linked GitHub accounts' do
      let!(:ccla) { create(:ccla) }

      before do
        user.accounts << create(:account, provider: 'github')
        sign_in user

        get :new
      end

      it { should respond_with(200) }
      it { should render_template('new') }

      it 'assigns @ccla_signature' do
        expect(assigns(:ccla_signature)).to_not be_nil
      end

      it 'ensures the signature will sign the latest CCLA' do
        expect(assigns(:ccla_signature).ccla).to eql(ccla)
      end
    end

  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:payload) { attributes_for(:ccla_signature, user_id: user.id) }
    before { sign_in user }

    context 'when the user has no linked GitHub accounts' do

      before do
        user.accounts.clear

        post :create, ccla_signature: {
          first_name: 'My',
          last_name: 'Doge'
        }
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(user)
      end

      it 'prompts the user to link their GitHub account' do
        expect(flash[:notice]).
          to eql(I18n.t('ccla_signature.requires_linked_github'))
      end

      it 'stores the signature page as the "stored location" for the user' do
        expect(controller.stored_location_for(user)).
          to eql(new_ccla_signature_path)
      end
    end

    context 'when the user has a linked GitHub account' do

      before do
        user.accounts << create(:account, provider: 'github')
      end

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

      it 'sends a notification that the CCLA has been signed' do
        expect {
          post :create, ccla_signature: payload
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end

