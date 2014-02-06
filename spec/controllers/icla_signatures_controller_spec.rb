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

      it 'assigns @icla_signature' do
        expect(assigns(:icla_signature)).to_not be_nil
      end

      it { should respond_with(200) }
      it { should render_template('new') }
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

        post :create, icla_signature: { user: { first_name: 'T', last_name: 'Rex' } }
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
        let(:payload) { attributes_for(:icla_signature).merge({ user_id: admin.id, user: attributes_for(:user) }) }

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
            post :create, icla_signature: { user: { prefix: 'Ms.' } }
          }.to_not change(IclaSignature, :count)
        end

        it 'renders the #new action' do
          post :create, icla_signature: { prefix: 'Ms.' }
          expect(response).to render_template('new')
        end
      end
    end
  end
end
