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

  describe 'PUT #destroy' do
    it 'allows authorized users to update contributors' do
      allow_any_instance_of(ContributorAuthorizer).to receive(:update?) { true }

      put :update, id: contributor.id, organization_id: organization.id,
        contributor: { admin: true }
      contributor.reload

      expect(contributor.admin).to eql(true)
    end

    it 'does not allow unauthorized users to update contributors' do
      allow_any_instance_of(ContributorAuthorizer).to receive(:update?) { false }

      put :update, id: contributor.id, organization_id: organization.id,
        contributor: { admin: true }
      contributor.reload

      expect(contributor.admin).to_not eql(true)
    end

    it 'authorizes that the logged-in users can update the contributor' do
      expect_any_instance_of(ContributorAuthorizer).to receive(:update?)

      put :update, id: contributor.id, organization_id: organization.id,
        contributor: { admin: true }
    end
  end

  describe 'DELETE #destroy' do
    it 'allows authorized users to delete contributors' do
      allow_any_instance_of(ContributorAuthorizer).to receive(:destroy?) { true }

      expect {
        delete :destroy, id: contributor.id, organization_id: organization.id
      }.to change(Contributor, :count).by(-1)
    end

    it 'does not allow unauthorized users to delete contributors' do
      allow_any_instance_of(ContributorAuthorizer).to receive(:destroy?) { false }

      expect {
        delete :destroy, id: contributor.id, organization_id: organization.id
      }.to_not change(Contributor, :count)
    end

    it 'authorizes that the logged-in users can remove the contributor' do
      expect_any_instance_of(ContributorAuthorizer).to receive(:destroy?)

      delete :destroy, id: contributor.id, organization_id: organization.id
    end
  end
end

