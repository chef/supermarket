class ContributorsController < ApplicationController
  before_filter :find_contributor, only: [:update, :destroy]

  #
  # PATCH /organizations/:organization_id/contributors/:id
  #
  # Update a single contributor.
  #
  def update
    authorize! @contributor

    @contributor.update_attributes(contributor_params)

    head 204
  end

  #
  # DELETE /organizations/:organization_id/contributors/:id
  #
  # Remove a single contributor.
  #
  def destroy
    authorize! @contributor

    @contributor.destroy

    redirect_to :back, notice: 'Contributor removed.'
  end

  #
  # GET /become-a-contributor
  #
  # Display information related to becoming a contributor.
  #
  def become_a_contributor
    store_location!
  end

  #
  # GET /contributors
  #
  # Display all of the users who have singed an ICLA or CCLA.
  #
  def index
    @all_signers = User.all_cla_signers
  end

  private

  def find_contributor
    @contributor = Contributor.find(params[:id])
  end

  def contributor_params
    params.require(:contributor).permit(:admin)
  end
end
