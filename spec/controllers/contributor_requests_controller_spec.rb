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

    def accept!
      get(
        :accept,
        ccla_signature_id: contributor_request.ccla_signature_id,
        id: contributor_request.id
      )
    end

    context 'when not signed in as an org admin' do
      it '404s' do
        non_admin_user = create(:user)

        sign_in(non_admin_user)

        accept!

        expect(response.code.to_i).to eql(404)
      end
    end

    context 'when signed in as an org admin' do
      let(:destination) do
        contributors_ccla_signature_path(contributor_request.ccla_signature)
      end

      before do
        admin_user = create(:user)
        contributor_request.organization.admins.create(user: admin_user)

        sign_in admin_user
      end

      context 'for pending requests' do
        it 'adds the requestor to the organization' do
          contributors = Contributor.where(
            organization_id: contributor_request.organization_id,
            user_id: contributor_request.user_id
          )

          expect do
            accept!
          end.to change(contributors, :count).by(1)
        end

        it 'sets the request state to accepted' do
          accept!

          expect(contributor_request.reload.state).to eql('accepted')
        end

        it 'redirects with success to the CCLA detail' do
          notice = I18n.t(
            'contributor_requests.accept.success',
            username: contributor_request.user.username,
            organization: contributor_request.organization.name
          )

          accept!

          expect(flash[:notice]).to eql(notice)

          expect(response).to redirect_to(destination)
        end
      end

      context 'for declined requests' do
        before do
          contributor_request.update_attributes!(state: 'declined')
        end

        it 'does not add the user to the organization' do
          contributors = Contributor.where(
            organization_id: contributor_request.organization_id,
            user_id: contributor_request.user_id
          )

          expect do
            accept!
          end.to_not change(contributors, :count)
        end

        it 'does not change the request state to declined' do
          accept!

          expect(contributor_request.reload.state).to eql('declined')
        end

        it 'redirects to the CCLA detail with an informative notice' do
          accept!

          notice = I18n.t(
            'contributor_requests.already.declined',
            username: contributor_request.user.username,
            organization: contributor_request.organization.name
          )

          expect(flash[:notice]).to eql(notice)

          expect(response).to redirect_to(destination)
        end
      end

      context 'for accepted requests' do
        before do
          contributor_request.organization.contributors.create(
            user: contributor_request.user
          )
          contributor_request.update_attributes!(state: 'accepted')
        end

        it 'keeps the request state as accepted' do
          accept!

          expect(contributor_request.reload.state).to eql('accepted')
        end

        it 'shows the same message as if this was the original acceptance' do
          accept!

          notice = I18n.t(
            'contributor_requests.accept.success',
            username: contributor_request.user.username,
            organization: contributor_request.organization.name
          )

          expect(flash[:notice]).to eql(notice)

          expect(response).to redirect_to(destination)
        end
      end
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

    it 'fulfulls pending requests' do
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

      expect(contributor_request.reload.state).to eql('declined')

      notice = I18n.t(
        'contributor_requests.decline.success',
        username: contributor_request.user.username,
        organization: contributor_request.organization.name
      )

      expect(flash[:notice]).to eql(notice)
    end

    it 'does not fulfull accepted requests' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)
      contributor_request.update_attributes!(state: 'accepted')

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      get :decline, ccla_signature_id: ccla_signature.id, id: contributor_request.id

      expect(contributor_request.reload.state).to eql('accepted')

      notice = I18n.t(
        'contributor_requests.already.accepted',
        username: contributor_request.user.username,
        organization: contributor_request.organization.name
      )

      expect(flash[:notice]).to eql(notice)
    end

    it 'handles redundant requests with grace' do
      admin_user = create(:user)
      contributor_request.organization.admins.create(user: admin_user)
      contributor_request.update_attributes!(state: 'declined')

      ccla_signature = contributor_request.ccla_signature

      sign_in admin_user

      get :decline, ccla_signature_id: ccla_signature.id, id: contributor_request.id

      expect(contributor_request.reload.state).to eql('declined')

      notice = I18n.t(
        'contributor_requests.decline.success',
        username: contributor_request.user.username,
        organization: contributor_request.organization.name
      )

      expect(flash[:notice]).to eql(notice)
    end
  end
end
