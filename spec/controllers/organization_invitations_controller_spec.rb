require "spec_helper"

describe OrganizationInvitationsController do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organizations: [organization]) }

  before { controller.stub(:current_user) { user } }

  describe 'GET #index' do
    it 'tells the view the organization' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:index?) { true }

      get :index, organization_id: organization.id

      expect(assigns[:organization]).to eql(organization)
    end

    it "tells the view the organization's invitations" do
      allow_any_instance_of(InvitationAuthorizer).to receive(:index?) { true }

      get :index, organization_id: organization.id

      expect(assigns[:invitations]).to be_empty

      get :index, organization_id: organization.id

      invitation = organization.invitations.create!(email: 'chef@example.com')

      expect(assigns[:invitations]).to include(invitation)
    end
  end

  describe 'POST #create' do
    before { controller.stub(:current_user) { user } }
    before { InvitationMailer.stub(:deliver_invitation) }

    it 'creates the invitation' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:create?) { true }

      expect do
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
      end.to change(organization.invitations, :count).by(1)
    end

    it 'sends the invitation' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:create?) { true }
      InvitationMailer.
        should_receive(:deliver_invitation).
        with(instance_of(Invitation))

      post :create,
        organization_id: organization.id,
        invitation: { email: 'chef@example.com' }
    end

    it 'authorizes that the user may send invitations' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:create?) { true }

      post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
    end

    it 'will not create an invitation if the user is not authorized to do so' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:create?) { false }

      expect do
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
      end.to_not change(Invitation, :count)
    end
  end
end
