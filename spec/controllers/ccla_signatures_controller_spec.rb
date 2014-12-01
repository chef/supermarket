require 'spec_helper'

describe CclaSignaturesController do
  context 'routes not requiring authentication' do
    describe 'GET #index' do
      let!(:org1) { create(:organization) }
      let!(:org2) { create(:organization) }
      let!(:ccla_signature1) { create(:ccla_signature, organization: org1, company: 'International House of Pancakes') }
      let!(:ccla_signature2) { create(:ccla_signature, organization: org2, company: "Bob's House of Pancakes") }

      context 'the format is html' do
        before { get :index }

        it { should respond_with(200) }
        it { should render_template('index') }

        it 'assigns @ccla_signatures' do
          expect(assigns(:ccla_signatures)).to include(ccla_signature1)
        end
      end

      context 'the format is json' do
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
    end

    describe 'GET #agreement' do
      before do
        create(:ccla)
        get :agreement
      end

      it 'should assign @cla_agreement' do
        expect(assigns(:cla_agreement)).to_not be_nil
      end

      it 'should work' do
        expect(response).to be_success
      end

      it 'should render the agreement template' do
        expect(response).to render_template('agreement')
      end
    end

    describe 'GET #contributors' do
      let(:ccla_signature) { create(:ccla_signature) }

      before do
        get :contributors, id: ccla_signature.id
      end

      it 'should assign @ccla_signature' do
        expect(assigns(:ccla_signature)).to_not be_nil
      end

      it 'should work' do
        expect(response).to be_success
      end

      it 'should render the contributors template' do
        expect(response).to render_template('contributors')
      end
    end
  end

  context 'routes requiring authentication' do
    describe 'GET #show' do
      let(:ccla_signature) { create(:ccla_signature) }
      before { sign_in(create(:user)) }

      context 'user is authorized to view CCLA Signature' do
        before do
          auto_authorize!(Organization, 'view_cclas')
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
          expect(response).to redirect_to(link_github_profile_path)
        end

        it 'prompts the user to link their GitHub account' do
          expect(flash[:notice]).
            to eql(I18n.t('requires_linked_github'))
        end

        it 'stores the signature page as the "stored location" for the user' do
          expect(controller.stored_location).to eql(new_ccla_signature_path)
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

      context 'when the user has no linked github accounts' do
        before do
          user.accounts.clear

          post :create, ccla_signature: {
            first_name: 'my',
            last_name: 'doge'
          }
        end

        it 'directs the user to link their github account' do
          expect(response).to redirect_to(link_github_profile_path)
        end

        it 'prompts the user to link their github account' do
          expect(flash[:notice]).
            to eql(I18n.t('requires_linked_github'))
        end

        it 'stores the previous url before directed to link github' do
          expect(controller.stored_location).to eql(ccla_signatures_path)
        end
      end

      context 'when the user has a linked github account' do
        before do
          user.accounts << create(:account, provider: 'github')

          allow(Curry::CommitAuthorVerificationWorker).to receive(:perform_async)
        end

        it 'creates a ccla signature for the current user' do
          expect { post :create, ccla_signature: payload }
          .to change(user.ccla_signatures, :count).by(1)
        end

        it 'creates an organization' do
          expect { post :create, ccla_signature: payload }
          .to change(Organization, :count).by(1)
        end

        it 'adds the current user to the newly-created organization' do
          expect { post :create, ccla_signature: payload }
          .to change(user.organizations, :count).by(1)
        end

        it 'sends a notification that the ccla has been signed' do
          Sidekiq::Testing.inline! do
            expect { post :create, ccla_signature: payload }
            .to change(ActionMailer::Base.deliveries, :count).by(1)
          end
        end

        it "changes the user's commit author records to have signed a CLA" do
          expect(Curry::CommitAuthorVerificationWorker).
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
      before do
        sign_in user
        auto_authorize!(Organization, 'resign_ccla')
      end

      context 'when the user has no linked github accounts' do
        before do
          user.accounts.clear

          post :re_sign, ccla_signature: {
            first_name: 'my',
            last_name: 'doge'
          }
        end

        it 'directs the user to link their github account' do
          expect(response).to redirect_to(link_github_profile_path)
        end

        it 'prompts the user to link their github account' do
          expect(flash[:notice]).
            to eql(I18n.t('requires_linked_github'))
        end

        it 'stores the previous url before directed to link github' do
          expect(controller.stored_location).
            to eql(re_sign_ccla_signatures_path)
        end
      end

      context 'when the user has a linked github account' do
        before do
          user.accounts << create(:account, provider: 'github')
        end

        it 'creates a ccla signature for the current user' do
          expect { post :re_sign, ccla_signature: payload }
          .to change(user.ccla_signatures, :count).by(1)
        end

        it 'maintains the original signing organization' do
          expect { post :re_sign, ccla_signature: payload }
          .to change(organization.ccla_signatures, :count).by(1)
        end
      end
    end
  end
end
