require "spec_helper"

describe OrganizationInvitationsController do

  let(:organization) { create(:organization) }
  let(:user) { create(:user, organizations: [organization]) }
  let(:authorizer) { InvitationAuthorizer.any_instance }

  before { controller.stub(:current_user) { user } }

  describe 'GET #index' do
    it 'tells the view the organization' do
      authorizer.stub(:index?) { true }

      get :index, organization_id: organization.id

      expect(assigns[:organization]).to eql(organization)
    end

    it "tells the view the organization's invitations" do
      authorizer.stub(:index?) { true }

      get :index, organization_id: organization.id

      expect(assigns[:invitations]).to be_empty

      get :index, organization_id: organization.id

      invitation = organization.invitations.create!(email: 'chef@example.com')

      expect(assigns[:invitations]).to include(invitation)
    end

    it 'authorizes the user wishing to invite collaborators' do
      authorizer.should_receive(:index?) { true }

      get :index, organization_id: organization.id
    end
  end

  describe 'POST #create' do
    before { controller.stub(:current_user) { user } }

    it 'creates the invitation' do
      authorizer.stub(:create?) { true }

      expect do
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
      end.to change(organization.invitations, :count).by(1)
    end

    it 'authorizes that the user may send invitations' do
      authorizer.should_receive(:create?) { true }

      post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
    end

    it 'will not create an invitation if the user is not authorized to do so' do
      authorizer.stub(:create?) { false }

      expect do
        post :create,
          organization_id: organization.id,
          invitation: { email: 'chef@example.com' }
      end.to_not change(Invitation, :count)
    end

  end

end
