require 'spec_helper'

describe CclaSignaturesController do
  describe 'GET #show' do
    let(:ccla_signature) { create(:ccla_signature) }
    before { sign_in(create(:user)) }

    context 'user is authorized to view CCLA Signature' do
      before do
        auto_authorize!(CclaSignature, 'show')
        get :show, id: ccla_signature.id
      end

      it 'assigns @ccla_signature' do
        expect(assigns(:ccla_signature)).to_not be_nil
      end

      it { should respond_with(200) }
    end

    context 'user is not authorized to view CCLA Signature' do
      before do
        get :show, id: ccla_signature.id
      end

      it { should respond_with(404) }
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
    let(:payload) { attributes_for(:ccla_signature).merge({ user_id: user.id, organization_attributes: attributes_for(:organization) }) }
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

      it 'stores the previous URL before directed to link GitHub' do
        expect(controller.stored_location_for(user)).
          to eql(ccla_signatures_path)
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

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:ccla_signature) { create(:ccla_signature) }
    before { sign_in(user) }

    context 'when the user has no linked GitHub accounts' do
      before do
        user.accounts.clear

        patch :update, id: ccla_signature.id,
          ccla_signature: { organization_attributes: { name: 'Cramer Development' } }
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(user)
      end

      it 'prompts the user to link their GitHub account' do
        expect(flash[:notice]).
          to eql(I18n.t('ccla_signature.requires_linked_github'))
      end

      it 'stores the previous URL before directed to link GitHub' do
        expect(controller.stored_location_for(user)).
          to eql(ccla_signature_path(ccla_signature))
      end
    end

    context 'when the user has a linked GitHub account' do
      before do
        user.accounts << create(:account, provider: 'github')
      end

      context 'user is authorized to update CCLA Signature' do
        before do
          auto_authorize!(CclaSignature, 'update')

          patch :update, id: ccla_signature.id,
            ccla_signature: { organization_attributes: { name: 'Cramer Development' } }

          ccla_signature.reload
       end

        it 'updates a related Organization' do
          expect(ccla_signature.organization.name).to eql('Cramer Development')
        end
      end

      context 'user is not authorized to update CCLA Signature' do
        before do
          patch :update, id: ccla_signature.id,
            ccla_signature: { organization_attributes: { name: 'Cramer Development' } }

          ccla_signature.reload
        end

        it 'does not update a related Organization' do
          expect(ccla_signature.organization.name).to_not eql('Cramer Development')
        end

        it { should respond_with(404) }
      end
    end
  end
end
