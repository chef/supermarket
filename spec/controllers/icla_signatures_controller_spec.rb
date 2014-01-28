require 'spec_helper'

describe IclaSignaturesController do
  let(:admin) { create(:user, roles: 'admin') }
  before { sign_in admin }

  describe 'GET #index' do
    before { get :index }

    it { should respond_with(200) }
    it { should render_template('index') }

    it 'assigns @icla_signatures' do
      signatures = create_list(:icla_signature, 2)
      expect(assigns(:icla_signatures)).to eq(signatures)
    end
  end

  describe 'GET #show' do
    let(:icla_signature) { create(:icla_signature) }
    before { get :show, id: icla_signature.id }

    it { should respond_with(200) }
    it { should render_template('show') }

    it 'assigns @icla_signature' do
      expect(assigns(:icla_signature)).to eq(icla_signature)
    end
  end

  describe 'GET #new' do
    context 'when the user has linked GitHub accounts' do
      before do
        admin.accounts << create(:account, provider: 'github')

        get :new
      end

      it { should respond_with(200) }
      it { should render_template('new') }

      it 'assigns @icla_signature' do
        icla_signature = assigns(:icla_signature)
        expect(icla_signature.prefix).to eq(admin.prefix)
        expect(icla_signature.first_name).to eq(admin.first_name)
        expect(icla_signature.middle_name).to eq(admin.middle_name)
        expect(icla_signature.last_name).to eq(admin.last_name)
        expect(icla_signature.suffix).to eq(admin.suffix)
        expect(icla_signature.email).to eq(admin.primary_email.try(:email))
        expect(icla_signature.phone).to eq(admin.phone)
        expect(icla_signature.company).to eq(admin.company)
      end
    end

    context 'when the user has no linked GitHub accounts' do
      before do
        admin.accounts.clear

        get :new
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(admin)
      end

      it 'prompts the user to link their GitHub account' do
        expect(flash[:notice]).
          to eql(I18n.t('icla_signature.requires_linked_github'))
      end

      it 'stores the signature page as the "stored location" for the user' do
        expect(controller.stored_location_for(admin)).
          to eql(new_icla_signature_path)
      end
    end
  end

  describe 'POST #create' do

    context 'when the user has no linked GitHub accounts' do

      before do
        admin.accounts.clear

        post :create, icla_signature: { first_name: 'T', last_name: 'Rex' }
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(admin)
      end

      it 'prompts the user to link their GitHub account' do
        expect(flash[:notice]).
          to eql(I18n.t('icla_signature.requires_linked_github'))
      end

      it 'stores the signature page as the "stored location" for the user' do
        expect(controller.stored_location_for(admin)).
          to eql(new_icla_signature_path)
      end

    end

    context 'when the user has a linked GitHub account' do

      before do
        admin.accounts << create(:account, provider: 'github')
      end

      context 'with valid attributes' do
        let(:payload) { attributes_for(:icla_signature, user_id: admin.id) }

        it 'creates a new ICLA signature' do
          expect {
            post :create, icla_signature: payload
          }.to change(IclaSignature, :count).by(1)
        end

        it 'sends a notification that the ICLA has been signed' do
          expect {
            post :create, icla_signature: payload
          }.to change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'redirects to the icla signature' do
          post :create, icla_signature: payload
          expect(response).to redirect_to(IclaSignature.last)
        end
      end

      context 'with invalid attributes' do
        it 'does not save the ICLA signature' do
          expect {
            post :create, icla_signature: { prefix: 'Ms.' }
          }.to_not change(IclaSignature, :count)
        end

        it 'renders the #new action' do
          post :create, icla_signature: { prefix: 'Ms.' }
          expect(response).to render_template('new')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:icla_signature) { create(:icla_signature) }
    before { delete :destroy, id: icla_signature }

    it { should redirect_to(icla_signatures_path) }

    it 'deletes the ICLA signature' do
      expect(IclaSignature.pluck(:id)).to_not include(icla_signature.id)
    end
  end
end
