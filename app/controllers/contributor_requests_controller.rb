class ContributorRequestsController < ApplicationController
  before_filter :authenticate_user!

  def create
    ccla_signature = CclaSignature.
      includes(:organization).
      find(params[:ccla_signature_id])
    organization = ccla_signature.organization

    contributor_request = ContributorRequest.new(
      user: current_user,
      organization: organization,
      ccla_signature: ccla_signature
    )

    authorize! contributor_request

    contributor_request.save!

    ContributorRequestNotifier.perform_async(contributor_request.id)

    redirect_to :back
  end

  def accept
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    ccla_signature = contributor_request.ccla_signature

    if contributor_request.presiding_admins.include?(current_user)
      if contributor_request.state == 'pending'
        organization = contributor_request.organization
        contributor = organization.contributors.new(
          user: contributor_request.user
        )

        if contributor.save
          destination = contributors_ccla_signature_path(ccla_signature)
          username = contributor_request.user.username
          organization_name = contributor_request.organization.name

          contributor_request.update_attributes!(state: 'accepted')

          ContributorRequestMailer.delay.request_accepted_email(contributor_request)

          notice = t(
            'contributor_requests.accept.success',
            username: username,
            organization: organization_name
          )

          redirect_to destination, notice: notice
        else
          # TODO: gracefully handle incidental uniqueness violations
        end
      else
        destination = contributors_ccla_signature_path(ccla_signature)
        username = contributor_request.user.username
        organization_name = contributor_request.organization.name

        if contributor_request.state == 'accepted'
          notice = t(
            'contributor_requests.accept.success',
            username: username,
            organization: organization_name
          )
        else
          notice = t(
            'contributor_requests.already.declined',
            username: username,
            organization: organization_name
          )
        end

        redirect_to destination, notice: notice
      end
    else
      raise NotAuthorizedError
    end
  end

  def decline
    contributor_request = ContributorRequest.where(
      ccla_signature_id: params[:ccla_signature_id],
      id: params[:id]
    ).first!

    ccla_signature = contributor_request.ccla_signature

    if contributor_request.presiding_admins.include?(current_user)
      destination = contributors_ccla_signature_path(ccla_signature)
      username = contributor_request.user.username
      organization_name = contributor_request.organization.name

      if contributor_request.state == 'pending'
        contributor_request.update_attributes!(state: 'declined')

        ContributorRequestMailer.delay.request_declined_email(contributor_request)

        notice = t(
          'contributor_requests.decline.success',
          username: username,
          organization: organization_name
        )
      else
        if contributor_request.state == 'declined'
          notice = t(
            'contributor_requests.decline.success',
            username: username,
            organization: organization_name
          )
        else
          notice = t(
            'contributor_requests.already.accepted',
            username: username,
            organization: organization_name
          )
        end
      end

      redirect_to destination, notice: notice
    else
      raise NotAuthorizedError
    end
  end
end
