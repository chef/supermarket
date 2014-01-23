require "spec_helper"

describe OrganizationInvitationsController do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organizations: [organization]) }
  before { sign_in user }

  describe 'GET #index' do

    it 'tells the view the organization' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:index?) { true }

      get :index, organization_id: organization.id

      expect(assigns[:organization]).to eql(organization)
    end

    describe "when selecting invitations to send to the view" do

      let!(:pending_invitation) do
        organization.invitations.create!(email: 'chef@example.com')
      end

      let!(:accepted_invitation) do
        organization.invitations.create!(
          email: 'chef@example.com',
          accepted: true
        )
      end

      let!(:declined_invitation) do
        organization.invitations.create!(
          email: 'chef@example.com',
          accepted: false
        )
      end

      it "tells the view the organization's pending invitations" do
        allow_any_instance_of(InvitationAuthorizer).to receive(:index?) { true }

        get :index, organization_id: organization.id

        expect(assigns[:pending_invitations]).to include(pending_invitation)
        expect(assigns[:pending_invitations]).to_not include(accepted_invitation)
        expect(assigns[:pending_invitations]).to_not include(declined_invitation)
      end

      it "tells the view the organization's declined invitations" do
        allow_any_instance_of(InvitationAuthorizer).to receive(:index?) { true }

        get :index, organization_id: organization.id

        expect(assigns[:declined_invitations]).to include(declined_invitation)
        expect(assigns[:declined_invitations]).to_not include(pending_invitation)
        expect(assigns[:declined_invitations]).to_not include(accepted_invitation)
      end
    end

    it "tells the view the organization's contributors" do
      allow_any_instance_of(InvitationAuthorizer).to receive(:index?) { true }

      get :index, organization_id: organization.id

      expect(assigns[:contributors]).to include(user.contributors.first)
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
