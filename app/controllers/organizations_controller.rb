class OrganizationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :find_organization, except: [:index]
  skip_before_filter :verify_authenticity_token, only: [:index]

  #
  # GET /organizations/:id
  #
  # Shows the management page for an organization, allowing deletion and
  # merging with other organizations.
  #
  def show
    authorize! @organization
  end

  #
  # DELETE /organizations/:id
  #
  # Deletes an organization
  #
  def destroy
    authorize! @organization
    organization_name = @organization.name
    @organization.destroy

    redirect_to ccla_signatures_path, notice: t('organizations.deleted', organization: organization_name)
  end

  #
  # PUT /organizations/:id/combine
  #
  # Combines two organizations together into one.
  #
  def combine
    authorize! @organization
    org_to_combine = Organization.find(params[:organization][:combine_with_id])
    org_to_combine_name = org_to_combine.name
    @organization.combine!(org_to_combine)

    redirect_to ccla_signatures_path, notice: t('organizations.combined', org_to_combine: org_to_combine_name, combined_with: @organization.name)
  end

  #
  # GET /organizations/:id/requests_to_join
  #
  # Shows a list of users who have requested to join the organization
  #
  def requests_to_join
    authorize! @organization, :manage_requests_to_join?

    @pending_requests = @organization.pending_requests_to_join
  end

  private

  def find_organization
    @organization = Organization.find(params[:id])
  end
end
