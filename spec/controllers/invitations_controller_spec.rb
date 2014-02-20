require 'spec_helper'

describe InvitationsController do
  let(:user) { create(:user) }
  let(:invitation) { create(:invitation) }
  before { sign_in user }

  describe 'GET #show' do
    it 'assigns an invitation' do
      get :show, id: invitation.token

      expect(assigns[:invitation]).to eql(invitation)
    end

    it 'redirects guests to sign in' do
      sign_out user
      get :show, id: invitation.token

      expect(response).to redirect_to(user_session_path)
    end
  end

  describe 'GET #accept' do
    it 'creates a new Contributor' do
      create(:account, user: user)
      expect {
        get :accept, id: invitation.token
      }.to change(Contributor, :count).by(1)
    end

    it 'accepts the invitation' do
      create(:account, user: user)
      get :accept, id: invitation.token
      invitation.reload

      expect(invitation.accepted).to eql(true)
    end

    it 'redirects to the current users profile if they have a connected GitHub account' do
      create(:account, user: user)
      get :accept, id: invitation.token

      expect(response).to redirect_to(user)
    end

    it 'redirects to link GitHub account if they no connected GitHub account' do
      get :accept, id: invitation.token

      expect(response).to redirect_to(link_github_profile_path)
    end

    it 'creates admins if the invitation specifies as such' do
      create(:account, user: user)
      invitation = create(:invitation, admin: true)

      expect {
        get :accept, id: invitation.token
      }.to change(Contributor.where(admin: true), :count).by(1)
    end

    it "it doesn't create a new Contributor if the same user already belongs to the CCLA (organization)" do
      create(:account, user: user)
      organization = create(:organization)
      invitation_1 = create(:invitation, organization: organization)
      invitation_2 = create(:invitation, organization: organization)

      expect {
        get :accept, id: invitation_1.token
        get :accept, id: invitation_2.token
      }.to_not change(Contributor, :count).by(2)
    end
  end

  describe 'GET #decline' do
    it 'declines the invitation' do
      get :decline, id: invitation.token
      invitation.reload

      expect(invitation.accepted).to eql(false)
    end

    it 'redirects to the current users profile' do
      get :decline, id: invitation.token

      expect(response).to redirect_to(user)
    end
  end
end
