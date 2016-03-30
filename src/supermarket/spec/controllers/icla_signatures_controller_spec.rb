require 'spec_helper'

describe IclaSignaturesController do
  context 'routes not requiring authentication' do
    describe 'GET #index' do
      let(:icla_signature) { create(:icla_signature) }
      before { get :index }

      it { should respond_with(200) }
      it { should render_template('index') }

      it 'assigns @icla_signatures' do
        expect(assigns(:icla_signatures)).to include(icla_signature)
      end

      context 'when searching for an icla signature' do
        let!(:jimmy_icla) { create(:icla_signature, first_name: 'Jimmy', last_name: 'John', email: 'someotheremail@chef.io') }
        let!(:billy_icla) { create(:icla_signature, first_name: 'Billy', last_name: 'Bob', email: 'thisdude@chef.io') }

        it 'returns icla signatures that match the search' do
          get :index, contributors_q: 'Jimmy'
          expect(assigns[:icla_signatures]).to include(jimmy_icla)
          expect(assigns[:icla_signatures]).to_not include(billy_icla)
        end
      end
    end

    describe 'GET #agreement' do
      before do
        create(:icla)
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
  end

  context 'routes requiring authentication' do
    let(:admin) { create(:user, roles: 'admin') }
    before { sign_in admin }

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
          expect(icla_signature.first_name).to eq(admin.first_name)
          expect(icla_signature.last_name).to eq(admin.last_name)
          expect(icla_signature.email).to eq(admin.email)
        end
      end

      context 'when the user has no linked GitHub accounts' do
        before do
          admin.accounts.clear

          get :new
        end

        it 'directs the user to link their github account' do
          expect(response).to redirect_to(link_github_profile_path)
        end

        it 'prompts the user to link their GitHub account' do
          expect(flash[:notice]).
            to eql(I18n.t('requires_linked_github'))
        end

        it 'stores the previous URL before directed to link GitHub' do
          expect(controller.stored_location).to eql(new_icla_signature_path)
        end
      end
    end

    describe 'POST #create' do
      context 'when the user has no linked GitHub accounts' do
        before do
          admin.accounts.clear

          post :create, icla_signature: { first_name: 'T', last_name: 'Rex' }
        end

        it 'directs the user to link their github account' do
          expect(response).to redirect_to(link_github_profile_path)
        end

        it 'prompts the user to link their GitHub account' do
          expect(flash[:notice]).
            to eql(I18n.t('requires_linked_github'))
        end

        it 'stores the previous URL before directed to link GitHub' do
          expect(controller.stored_location).to eql(icla_signatures_path)
        end
      end

      context 'when the user has a linked GitHub account' do
        before do
          admin.accounts << create(:account, provider: 'github')

          allow(Curry::CommitAuthorVerificationWorker).to receive(:perform_async)
        end

        context 'with valid attributes' do
          let(:payload) { attributes_for(:icla_signature, user_id: admin.id) }

          it 'creates a new ICLA signature' do
            expect { post :create, icla_signature: payload }
            .to change(IclaSignature, :count).by(1)
          end

          it 'sends a notification that the ICLA has been signed' do
            Sidekiq::Testing.inline! do
              expect { post :create, icla_signature: payload }
              .to change(ActionMailer::Base.deliveries, :count).by(1)
            end
          end

          it 'redirects to the icla signature' do
            post :create, icla_signature: payload
            expect(response).to redirect_to(icla_signatures_path)
          end

          it "changes the user's commit author records to have signed a CLA" do
            expect(Curry::CommitAuthorVerificationWorker).
              to receive(:perform_async).
              with(admin.id)

            post :create, icla_signature: payload
          end
        end

        context 'with invalid attributes' do
          it 'does not save the ICLA signature' do
            expect { post :create, icla_signature: { prefix: 'Ms.' } }
            .to_not change(IclaSignature, :count)
          end

          it 'renders the #new action' do
            post :create, icla_signature: { prefix: 'Ms.' }
            expect(response).to render_template('new')
          end
        end
      end
    end

    describe 'POST #re_sign' do
      context 'when the user has no linked GitHub accounts' do
        before do
          admin.accounts.clear

          post :re_sign, icla_signature: { first_name: 'T', last_name: 'Rex' }
        end

        it 'redirects the user to their profile' do
          expect(response).to redirect_to(link_github_profile_path)
        end

        it 'prompts the user to link their GitHub account' do
          expect(flash[:notice]).
            to eql(I18n.t('requires_linked_github'))
        end

        it 'stores the previous URL before directed to link GitHub' do
          expect(controller.stored_location).
            to eql(re_sign_icla_signatures_path)
        end
      end

      context 'when the user has a linked GitHub account' do
        before do
          admin.accounts << create(:account, provider: 'github')
        end

        context 'with valid attributes' do
          let(:payload) { attributes_for(:icla_signature, user_id: admin.id) }

          it 'creates a new ICLA signature' do
            expect { post :re_sign, icla_signature: payload }
            .to change(IclaSignature, :count).by(1)
          end

          it 'redirects to the icla signature' do
            post :re_sign, icla_signature: payload
            expect(response).to redirect_to(icla_signatures_path)
          end
        end

        context 'with invalid attributes' do
          it 'does not save the ICLA signature' do
            expect { post :re_sign, icla_signature: { prefix: 'Ms.' } }
            .to_not change(IclaSignature, :count)
          end

          it 'renders the #show action' do
            post :re_sign, icla_signature: { prefix: 'Ms.' }
            expect(response).to render_template('show')
          end
        end
      end
    end
  end
end
