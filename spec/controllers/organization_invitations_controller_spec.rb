require 'spec_helper'

describe OrganizationInvitationsController do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organizations: [organization]) }
  before { sign_in user }

  describe 'GET #index' do
    context 'user is authorized to view invitations' do
      before do
        auto_authorize!(Invitation, 'index')
        get :index, organization_id: organization.id
      end

      it 'tells the view the organization' do
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
          expect(assigns[:pending_invitations]).to include(pending_invitation)
          expect(assigns[:pending_invitations]).to_not include(accepted_invitation)
          expect(assigns[:pending_invitations]).to_not include(declined_invitation)
        end

        it "tells the view the organization's declined invitations" do
          expect(assigns[:declined_invitations]).to include(declined_invitation)
          expect(assigns[:declined_invitations]).to_not include(pending_invitation)
          expect(assigns[:declined_invitations]).to_not include(accepted_invitation)
        end
      end

      it "tells the view the organization's contributors" do
        expect(assigns[:contributors]).to include(user.contributors.first)
      end
    end
  end

  describe 'POST #create' do
    context 'user is authorized to create an Invitation' do
      before { auto_authorize!(Invitation, 'create') }

      it 'creates the invitation' do
        expect {
          post :create,
            organization_id: organization.id,
            invitation: { email: 'chef@example.com' }
        }.to change(organization.invitations, :count).by(1)
      end

      it 'sends the invitation' do
        expect {
          post :create,
            organization_id: organization.id,
            invitation: { email: 'chef@example.com' }
        }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    context 'user is not authorized to create an Invitation' do
      it "doesn't create the invitation" do
        expect do
          post :create,
            organization_id: organization.id,
            invitation: { email: 'chef@example.com' }
        end.to_not change(Invitation, :count)
      end

      it 'responds with 404' do
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }

        should respond_with(404)
      end
    end
  end

  describe 'PATCH #update' do
    let(:invitation) { create(:invitation, admin: true) }

    context 'user is authorized to update an Invitation' do
      before { auto_authorize!(Invitation, 'update') }

      it 'updates an invitation' do
        patch :update, organization_id: organization.id,
          id: invitation.token, invitation: { admin: false }

        invitation.reload

        expect(invitation.admin).to be_false
      end
    end

    context 'user is not authorized to update an Invitation' do
      it "doesn't update the invitation" do
        patch :update, organization_id: organization.id,
          id: invitation.token, invitation: { admin: false }

        invitation.reload

        expect(invitation.admin).to be_true
      end

      it 'responds wtih 404' do
        patch :update, organization_id: organization.id,
          id: invitation.token, invitation: { admin: false }

        should respond_with(404)
      end
    end
  end

  describe 'PATCH #resend' do
    let(:invitation) { create(:invitation) }
    before { request.env['HTTP_REFERER'] = 'the_previous_path' }

    context 'user is authorized to resend Invitation' do
      before { auto_authorize!(Invitation, 'resend') }

      it 'resends the invitation' do
        expect {
          patch :resend, organization_id: organization.id,
            id: invitation.token
        }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    context 'user is not authorized to resend Invitation' do
      it "doesn't resend the invitation" do
        expect {
          patch :resend, organization_id: organization.id,
            id: invitation.token
        }.to_not change(ActionMailer::Base.deliveries, :size).by(1)
      end

      it 'responds with 404' do
        patch :resend, organization_id: organization.id,
          id: invitation.token

        should respond_with(404)
      end
    end
  end
end
