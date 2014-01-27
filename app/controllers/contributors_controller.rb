class ContributorsController < ApplicationController
  before_filter :find_contributor

  #
  # PUT /organizations/:organization_id/contributors/:id
  #
  # Update a single contributor.
  #
  def update
    authorize! @contributor

    @contributor.update_attributes(contributor_params)

    render json: @contributor
  end

  #
  # DELETE /organizations/:organization_id/contributors/:id
  #
  # Remove a single contributor.
  #
  def destroy
    authorize! @contributor

    @contributor.destroy

    redirect_to :back, notice: "Contributor removed."
  end

  private
    def find_contributor
      @contributor = Contributor.find(params[:id])
    end

    def contributor_params
      params.require(:contributor).permit(:admin)
    end
end

