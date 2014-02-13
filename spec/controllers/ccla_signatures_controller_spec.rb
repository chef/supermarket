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

  describe 'post #create' do
    let(:user) { create(:user) }
    let(:payload) { attributes_for(:ccla_signature, user_id: user.id) }
    before { sign_in user }

    context 'when the user has no linked github accounts' do
      before do
        user.accounts.clear

        post :create, ccla_signature: {
          first_name: 'my',
          last_name: 'doge'
        }
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(user)
      end

      it 'prompts the user to link their github account' do
        expect(flash[:notice]).
          to eql(I18n.t('ccla_signature.requires_linked_github'))
      end

      it 'stores the previous url before directed to link github' do
        expect(controller.stored_location_for(user)).
          to eql(ccla_signatures_path)
      end
    end

    context 'when the user has a linked github account' do
      before do
        user.accounts << create(:account, provider: 'github')

        allow(Curry::PullRequestAppraiserWorker).to receive(:perform_async)
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

      it 'sends a notification that the ccla has been signed' do
        expect {
          post :create, ccla_signature: payload
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it "appraises that user's pull requests" do
        expect(Curry::PullRequestAppraiserWorker).
          to receive(:perform_async).
          with(user.id)

        post :create, ccla_signature: payload
      end
    end
  end

  describe 'post #re_sign' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }
    let(:payload) { attributes_for(:ccla_signature, user_id: user.id, organization_id: organization.id) }
    before { sign_in user }

    context 'when the user has no linked github accounts' do
      before do
        user.accounts.clear

        post :re_sign, ccla_signature: {
          first_name: 'my',
          last_name: 'doge'
        }
      end

      it 'redirects the user to their profile' do
        expect(response).to redirect_to(user)
      end

      it 'prompts the user to link their github account' do
        expect(flash[:notice]).
          to eql(I18n.t('ccla_signature.requires_linked_github'))
      end

      it 'stores the previous url before directed to link github' do
        expect(controller.stored_location_for(user)).
          to eql(re_sign_ccla_signatures_path)
      end
    end

    context 'when the user has a linked github account' do
      before do
        user.accounts << create(:account, provider: 'github')
      end

      it 'creates a ccla signature for the current user' do
        expect {
          post :re_sign, ccla_signature: payload
        }.to change(user.ccla_signatures, :count).by(1)
      end

      it 'maintains the original signing organization' do
        expect {
          post :re_sign, ccla_signature: payload
        }.to change(organization.ccla_signatures, :count).by(1)
      end
    end
  end
end
