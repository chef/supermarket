require 'spec_helper'

describe ContributorsController do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user) }
  let!(:contributor) do
    create(:contributor, {
      user: user,
      organization: organization,
      admin: false
    })
  end

  before do
    request.env["HTTP_REFERER"] = "http://example.com/back"
    sign_in user
  end

  describe 'PATCH #update' do
    context 'user is authorized to update Contributor' do
      before do
        auto_authorize!(Contributor, 'update')
        put :update, id: contributor.id, organization_id: organization.id,
          contributor: { admin: true }

        contributor.reload
      end

      it 'updates the contributor' do
        expect(contributor.admin).to eql(true)
      end
    end

    context 'user is not authorized to update Contributor' do
      before do
        put :update, id: contributor.id, organization_id: organization.id,
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
        expect {
          delete :destroy, id: contributor.id, organization_id: organization.id
        }.to change(Contributor, :count).by(-1)
      end

      it 'redirects the user back' do
        delete :destroy, id: contributor.id, organization_id: organization.id
        should redirect_to :back
      end
    end

    context 'user is not authorized to destroy Contributor' do
      it "doesn't destroy the contributor" do
        expect {
          delete :destroy, id: contributor.id, organization_id: organization.id
        }.to_not change(Contributor, :count)
      end

      it 'responds with 404' do
        delete :destroy, id: contributor.id, organization_id: organization.id
        should respond_with(404)
      end
    end
  end
end
