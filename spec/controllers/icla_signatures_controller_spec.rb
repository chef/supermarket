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
    before { sign_in(create(:user)) }

    context 'user is authorized to view ICLA Signature' do
      before do
        auto_authorize!(IclaSignature, 'show')
        get :show, id: icla_signature.id
      end

      it 'assigns @icla_signature' do
        expect(assigns(:icla_signature)).to_not be_nil
      end

      it { should respond_with(200) }
    end

    context 'user is not authorized to view ICLA Signature' do
      before do
        get :show, id: icla_signature.id
      end

      it { should respond_with(404) }
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
        expect(icla_signature.email).to eq(admin.email)
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

      it 'stores the previous URL before directed to link GitHub' do
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

      it 'stores the previous URL before directed to link GitHub' do
        expect(controller.stored_location_for(admin)).
          to eql(icla_signatures_path)
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

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:icla_signature) { create(:icla_signature, email: 'jim@example.com') }
    before { sign_in(user) }

    context 'when the user has no linked GitHub accounts' do
      before do
        user.accounts.clear

        patch :update, id: icla_signature.id,
          icla_signature: { email: 'jack@example.com' }
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(user)
      end

      it 'prompts the user to link their GitHub account' do
        expect(flash[:notice]).
          to eql(I18n.t('icla_signature.requires_linked_github'))
      end

      it 'stores the previous URL before directed to link GitHub' do
        expect(controller.stored_location_for(user)).
          to eql(icla_signature_path(icla_signature))
      end
    end

    context 'when the user has a linked GitHub account' do
      before do
        user.accounts << create(:account, provider: 'github')
      end

      context 'user is authorized to update ICLA Signature' do
        before do
          auto_authorize!(IclaSignature, 'update')

          patch :update, id: icla_signature.id,
            icla_signature: { email: 'jack@example.com' }

          icla_signature.reload
       end

        it 'updates a ICLA Signature' do
          expect(icla_signature.email).to eql('jack@example.com')
        end
      end

      context 'user is not authorized to update ICLA Signature' do
        before do
          patch :update, id: icla_signature.id,
            icla_signature: { email: 'jack@example.com' }

          icla_signature.reload
        end

        it 'does not update a ICLA Signature' do
          expect(icla_signature.email).to eql('jim@example.com')
        end

        it { should respond_with(404) }
      end
    end
  end
end
