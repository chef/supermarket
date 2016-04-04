require 'spec_helper'

describe ContributorsController do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, first_name: 'Billy', last_name: 'Bob', email: 'billybob@chef.io') }
  let!(:contributor) do
    create :contributor,
           user: user,
           organization: organization,
           admin: false
  end

  before do
    request.env['HTTP_REFERER'] = 'http://example.com/back'
    sign_in user
  end

  describe 'PATCH #update' do
    context 'user is authorized to update Contributor' do
      before do
        auto_authorize!(Contributor, 'update')
        put :update,
            id: contributor.id,
            organization_id: organization.id,
            contributor: { admin: true }

        contributor.reload
      end

      it 'updates the contributor' do
        expect(contributor.admin).to eql(true)
      end
    end

    context 'user is not authorized to update Contributor' do
      before do
        put :update,
            id: contributor.id,
            organization_id: organization.id,
            contributor: { admin: true }

        contributor.reload
      end

      it "doesn't update the contributor" do
        expect(contributor.admin).to_not eql(true)
      end

      it { should respond_with(404) }
    end
  end

  describe 'DELETE #destroy' do
    context 'user is authorized to destroy Contributor' do
      before { auto_authorize!(Contributor, 'destroy') }

      it 'destroys the contributor' do
        expect { delete :destroy, id: contributor.id, organization_id: organization.id }
        .to change(Contributor, :count).by(-1)
      end

      it 'redirects the user back' do
        delete :destroy, id: contributor.id, organization_id: organization.id
        should redirect_to :back
      end
    end

    context 'user is not authorized to destroy Contributor' do
      it "doesn't destroy the contributor" do
        expect { delete :destroy, id: contributor.id, organization_id: organization.id }
        .to_not change(Contributor, :count)
      end

      it 'responds with 404' do
        delete :destroy, id: contributor.id, organization_id: organization.id
        should respond_with(404)
      end
    end
  end

  describe 'GET #become_a_contributor' do
    it 'responds with a 200' do
      get :become_a_contributor

      expect(response.status.to_i).to eql(200)
    end
  end

  describe 'GET #index' do
    it 'responds with a 200' do
      get :index

      expect(response.status.to_i).to eql(200)
    end

    it 'assigns contributors' do
      get :index

      expect(assigns[:contributors]).to_not be_nil
    end

    it 'assigns contributor_list' do
      get :index

      expect(assigns[:contributor_list]).to_not be_nil
    end

    context 'when searching for a contributor' do
      let(:sample_username) { 'billybob' }

      before do
        allow(user).to receive(:username).and_return(sample_username)
      end

      it 'includes the contributor being searched for' do
        get :index, contributors_q: sample_username

        expect(assigns[:contributors]).to include(user)
      end

      it 'does not include a contributor not being searched for' do
        other_user = User.first
        expect(other_user).to_not eq(user)
        allow(other_user).to receive(:username).and_return('sallysue')

        get :index, contributors_q: user.username

        expect(assigns[:contributors]).to_not include(other_user)
      end

      context 'when a contributor is not authorized' do
        let(:new_user) { create(:user) }

        before do
          expect(User.authorized_contributors).to_not include(new_user)
        end

        it 'does not include the contributor' do
          get :index, contributors_q: new_user.username

          expect(assigns[:contributors]).to_not include(new_user)
        end
      end
    end
  end
end
