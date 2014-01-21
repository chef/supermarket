class OrganizationUsersController < ApplicationController
  def destroy
    organization_user = OrganizationUser.find(params[:id])

    authorize! organization_user

    organization_user.destroy

    flash[:notice] = "Organization User removed."

    redirect_to :back
  end
end
