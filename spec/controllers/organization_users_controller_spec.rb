require 'spec_helper'

describe OrganizationUsersController do

  describe 'DELETE #destroy' do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user) }
    let!(:organization_user) do
      create(:organization_user, {
        user: user,
        organization: organization,
        admin: false
      })
    end

    before do
      request.env["HTTP_REFERER"] = "http://example.com/back"
      subject.stub(:current_user).and_return(user)
    end

    it 'allows authorized users to delete contributors' do
      allow_any_instance_of(OrganizationUserAuthorizer).to receive(:destroy?) { true }

      expect {
        delete :destroy, id: organization_user.id, organization_id: organization.id
      }.to change(OrganizationUser, :count).by(-1)
    end

    it 'does not allow unauthorized users to delete contributors' do
      allow_any_instance_of(OrganizationUserAuthorizer).to receive(:destroy?) { false }

      expect {
        delete :destroy, id: organization_user.id, organization_id: organization.id
      }.to_not change(OrganizationUser, :count)
    end

    it 'authorizes that the logged-in users can remove the contributor' do
      expect_any_instance_of(OrganizationUserAuthorizer).to receive(:destroy?)

      delete :destroy, id: organization_user.id, organization_id: organization.id
    end

  end

end
