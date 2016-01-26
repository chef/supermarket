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

      expect(response.status.to_i).to eql(404)
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

    it 'renders the pending approval partial on success' do
      sign_in(contributing_user)

      post :create, ccla_signature_id: ccla_signature.id

      expect(response).to render_template('ccla_signatures/_pending_approval')
    end
  end

  describe '#accept' do
    let!(:contributor_request) { create(:contributor_request) }

    def accept!
      Sidekiq::Testing.inline! do
        get(
          :accept,
          ccla_signature_id: contributor_request.ccla_signature_id,
          id: contributor_request.id
        )
      end
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

        it 'sends an email to the requestor' do
          requestor_delivery_count = lambda do
            ActionMailer::Base.deliveries.select do |message|
              message.to.include?(contributor_request.user.email)
            end.count
          end

          expect do
            accept!
          end.to change(&requestor_delivery_count).by(1)
        end
      end

      context 'for declined requests' do
        before do
          contributor_request.decline
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

        it 'does not send an email to the requestor' do
          requestor_delivery_count = lambda do
            ActionMailer::Base.deliveries.select do |message|
              message.to.include?(contributor_request.user.email)
            end.count
          end

          expect do
            accept!
          end.to_not change(&requestor_delivery_count)
        end
      end

      context 'for accepted requests' do
        before do
          contributor_request.accept
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

        it 'does not send an email to the requestor' do
          requestor_delivery_count = lambda do
            ActionMailer::Base.deliveries.select do |message|
              message.to.include?(contributor_request.user.email)
            end.count
          end

          expect do
            accept!
          end.to_not change(&requestor_delivery_count)
        end
      end
    end
  end

  describe '#decline' do
    let!(:contributor_request) { create(:contributor_request) }

    def decline!
      Sidekiq::Testing.inline! do
        get(
          :decline,
          ccla_signature_id: contributor_request.ccla_signature_id,
          id: contributor_request.id
        )
      end
    end

    context 'when not signed in as an org admin' do
      it '404s' do
        non_admin_user = create(:user)

        sign_in(non_admin_user)

        decline!

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

        sign_in(admin_user)
      end

      context 'for pending requests' do
        it 'redirects to the CCLA detail with a notice' do
          decline!

          notice = I18n.t(
            'contributor_requests.decline.success',
            username: contributor_request.user.username,
            organization: contributor_request.organization.name
          )

          expect(flash[:notice]).to eql(notice)

          expect(response).to redirect_to(destination)
        end

        it 'sends an email to the requestor' do
          requestor_delivery_count = lambda do
            ActionMailer::Base.deliveries.select do |message|
              message.to.include?(contributor_request.user.email)
            end.count
          end

          expect do
            decline!
          end.to change(&requestor_delivery_count).by(1)
        end
      end

      context 'for accepted requests' do
        before do
          contributor_request.accept
        end

        it 'redirects to the CCLA detail with a notice' do
          decline!

          notice = I18n.t(
            'contributor_requests.already.accepted',
            username: contributor_request.user.username,
            organization: contributor_request.organization.name
          )

          expect(flash[:notice]).to eql(notice)

          expect(response).to redirect_to(destination)
        end

        it 'does not send an email to the requestor' do
          requestor_delivery_count = lambda do
            ActionMailer::Base.deliveries.select do |message|
              message.to.include?(contributor_request.user.email)
            end.count
          end

          expect do
            decline!
          end.to_not change(&requestor_delivery_count)
        end
      end

      context 'for declined requests' do
        before do
          contributor_request.decline
        end

        it 'redirects to the CCLA detail with the same notice as the first decline' do
          decline!

          notice = I18n.t(
            'contributor_requests.decline.success',
            username: contributor_request.user.username,
            organization: contributor_request.organization.name
          )

          expect(flash[:notice]).to eql(notice)

          expect(response).to redirect_to(destination)
        end

        it 'does not send an email to the requestor' do
          requestor_delivery_count = lambda do
            ActionMailer::Base.deliveries.select do |message|
              message.to.include?(contributor_request.user.email)
            end.count
          end

          expect do
            decline!
          end.to_not change(&requestor_delivery_count)
        end
      end
    end
  end
end
