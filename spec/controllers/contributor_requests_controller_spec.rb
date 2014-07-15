require 'spec_helper'

describe ContributorRequestsController do
  describe '#create' do
    before do
      request.env['HTTP_REFERER'] = '/'
    end

    let(:contributing_user) { create(:user) }
    let!(:ccla_signature) { create(:ccla_signature) }

    it 'requires authentication' do
      post :create, ccla_signature_id: ccla_signature.id

      expect(response).to redirect_to(sign_in_url)
    end

    it '404s if the given CCLA Signature does not exist' do
      sign_in(contributing_user)

      post :create, ccla_signature_id: -1

      expect(response.code.to_i).to eql(404)
    end

    it 'does not allow existing contributors to make requests' do
      create(
        :contributor,
        organization: ccla_signature.organization,
        user: contributing_user
      )

      sign_in(contributing_user)

      post :create, ccla_signature_id: ccla_signature.id

      expect(response).to render_template('exceptions/404')
    end

    it 'creates a ContributorRequest for users new to the Organization' do
      sign_in(contributing_user)

      contributor_requests = ContributorRequest.where(
        organization_id: ccla_signature.organization_id,
        user_id: contributing_user.id
      )

      expect do
        post :create, ccla_signature_id: ccla_signature.id
      end.to change(contributor_requests, :count).from(0).to(1)
    end

    it 'queues a job to send emails regarding the request' do
      sign_in(contributing_user)

      expect do
        post :create, ccla_signature_id: ccla_signature.id
      end.to change(ContributorRequestNotifier.jobs, :count).by(1)
    end

    it 'redirects back on success' do
      sign_in(contributing_user)

      post :create, ccla_signature_id: ccla_signature.id

      expect(response).to redirect_to('/')
    end
  end

  describe '#accept' do
    let!(:contributor_request) { create(:contributor_request) }

    it '404s if the current user is not an org admin' do
      non_admin_user = create(:user)

      sign_in(non_admin_user)

      get :accept, ccla_signature_id: contributor_request.ccla_signature_id, id: contributor_request.id

      expect(response.code.to_i).to eql(404)
    end

    it 'redirects to the organization if the current user is an org admin' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      get :accept, ccla_signature_id: ccla_signature.id, id: contributor_request.id

      expect(response).
        to redirect_to(contributors_ccla_signature_path(ccla_signature))
    end

    it 'adds the requestor to the requested organization if the request is pending' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)

      contributors = Contributor.where(
        organization_id: contributor_request.organization_id,
        user_id: contributor_request.user_id
      )

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      expect do
        get :accept, ccla_signature_id: ccla_signature.id, id: contributor_request.id
      end.to change(contributors, :count).by(1)
    end

    it 'does not add the requestor if the request has been declined' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)
      contributor_request.update_attributes!(state: 'declined')

      contributors = Contributor.where(
        organization_id: contributor_request.organization_id,
        user_id: contributor_request.user_id
      )

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      expect do
        get :accept, ccla_signature_id: ccla_signature.id, id: contributor_request.id
      end.to_not change(contributors, :count)
    end

    it 'marks the request as accepted' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      get :accept, ccla_signature_id: ccla_signature.id, id: contributor_request.id

      expect(contributor_request.reload.state).to eql('accepted')
    end
  end

  describe '#decline' do
    let!(:contributor_request) { create(:contributor_request) }

    it '404s if the current user is not an org admin' do
      non_admin_user = create(:user)

      sign_in(non_admin_user)

      get :decline, ccla_signature_id: contributor_request.ccla_signature_id, id: contributor_request.id

      expect(response.code.to_i).to eql(404)
    end

    it 'redirects to the organization if the current user is an org admin' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      get :decline, ccla_signature_id: ccla_signature.id, id: contributor_request.id

      expect(response).
        to redirect_to(contributors_ccla_signature_path(ccla_signature))
    end

    it 'does not add the requestor to the requested organization' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)

      contributors = Contributor.where(
        organization_id: contributor_request.organization_id,
        user_id: contributor_request.user_id
      )

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      expect do
        get :decline, ccla_signature_id: ccla_signature.id, id: contributor_request.id
      end.to_not change(contributors, :count)
    end

    it 'marks the request state as declined' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      get :decline, ccla_signature_id: ccla_signature.id, id: contributor_request.id

      expect(contributor_request.reload.state).to eql('declined')
    end
  end
end
