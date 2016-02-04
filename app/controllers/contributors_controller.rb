class ContributorsController < ApplicationController
  before_action :find_contributor, only: [:update, :destroy]

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

    redirect_to :back, notice: t('contributor.removed')
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
  # Display all of the users who are authorized to contribute
  #
  def index
    if params[:contributors_q].present?
      # Finds the intersection between the users returned by the search
      # and the list of users who are authorized contributors
      contributors = User.search(params[:contributors_q]) & User.authorized_contributors

    else
      contributors = User.authorized_contributors
    end

    # Using Kaminari.paginate_array because finding the intersection of two active record relations returns an array
    @contributors = Kaminari.paginate_array(contributors).page(params[:page]).per(20)

    @contributor_list = ContributorList.new(@contributors)
  end

  private

  def find_contributor
    @contributor = Contributor.find(params[:id])
  end

  def contributor_params
    params.require(:contributor).permit(:admin)
  end
end
