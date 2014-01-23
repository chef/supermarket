class ContributorsController < ApplicationController
  def destroy
    contributor = Contributor.find(params[:id])

    authorize! contributor

    contributor.destroy

    redirect_to :back, notice: "Contributor removed."
  end
end
