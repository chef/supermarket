class OrganizationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :find_organization, except: [:index]
  skip_before_filter :verify_authenticity_token, only: [:index]

  #
  # GET /organizations
  #
  # Lists out all organizations.
  #
  def index
    organizations = if params[:q]
                      CclaSignature.where('company like ?', "%#{params[:q]}%")
                    else
                      Organization.includes(:ccla_signatures)
                    end

    respond_to do |format|
      format.json do
        render json: organizations.to_json(only: [:id], methods: [:company])
      end
    end
  end

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
    @organization.destroy

    redirect_to root_path
  end

  #
  # PUT /organizations/:id/combine
  #
  # Combines two organizations together into one.
  #
  def combine
    authorize! @organization
    org_to_combine = Organization.find(params[:organization][:combine_with_id])
    @organization.combine!(org_to_combine)

    redirect_to @organization
  end

  private

  def find_organization
    @organization = Organization.find(params[:id])
  end
end
