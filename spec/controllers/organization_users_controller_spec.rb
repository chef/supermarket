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

    let!(:admin) { create(:user) }
    let!(:organization_admin) do
      create(:organization_user, {
        user: admin,
        organization: organization,
        admin: true
      })
    end

    before do
      request.env["HTTP_REFERER"] = "http://example.com/back"
      subject.stub(:current_user).and_return(admin)
    end

    it 'deletes contributors' do
      expect {
        delete :destroy, id: organization_user.id, organization_id: organization.id
      }.to change(OrganizationUser, :count).by(-1)
    end

    it "fails to delete contributors outside of the admin's organization" do
      other_organization_user = create(:organization_user)

      expect {
        delete :destroy, id: other_organization_user.id,
          organization_id: organization.id
      }.to_not change(OrganizationUser, :count)
    end

    it 'fails if the current_user is not an admin of that organization' do
      other_user = create(:user)
      subject.stub(:current_user).and_return(other_user)

      expect {
        delete :destroy, id: organization_user.id,
          organization_id: organization.id
      }.to_not change(OrganizationUser, :count)
    end

    it 'fails if the current_user is the only remaining organization admin' do
      expect {
        delete :destroy, id: organization_admin.id,
          organization_id: organization.id
      }.to_not change(OrganizationUser, :count)
    end

  end

end
