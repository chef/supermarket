require 'spec_helper'

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

    describe 'when selecting invitations to send to the view' do
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
    it 'creates the invitation' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:create?) { true }

      expect {
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
      }.to change(organization.invitations, :count).by(1)
    end

    it 'sends the invitation' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:create?) { true }

      expect {
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
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

  describe 'PATCH #update' do
    let(:invitation) { create(:invitation, admin: true) }

    it 'updates an invitation' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:update?) { true }

      patch :update, organization_id: organization.id,
        id: invitation.token, invitation: { admin: false }

      invitation.reload

      expect(invitation.admin).to be_false
    end

    it 'will not update an invitation if the user is not auhtorized to do so' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:update?) { false }

      patch :update, organization_id: organization.id,
        id: invitation.token, invitation: { admin: false }

      invitation.reload

      expect(invitation.admin).to be_true
    end
  end

  describe 'PATCH #resend' do
    let(:invitation) { create(:invitation) }
    before { request.env['HTTP_REFERER'] = 'the_previous_path' }

    it 'resends the invitation' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:resend?) { true }

      expect {
        patch :resend, organization_id: organization.id,
          id: invitation.token
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end

    it 'will not resend the invitation if the user is not authorized to do so' do
      allow_any_instance_of(InvitationAuthorizer).to receive(:resend?) { false }

      expect {
        patch :resend, organization_id: organization.id,
          id: invitation.token
      }.to_not change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end
end
