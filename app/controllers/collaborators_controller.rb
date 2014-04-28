class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_cookbook
  skip_before_filter :verify_authenticity_token, only: [:destroy]

  #
  # GET /cookbooks/:cookbook_id/collaborators?q=jimmy
  #
  # Searches for someone by username.
  #
  def index
    @collaborators = eligible_collaborators.limit(20)

    if params[:q]
      @collaborators = @collaborators.search(params[:q])
    end

    respond_to do |format|
      format.json
    end
  end

  #
  # GET /cookbooks/:cookbook_id/collaborators/new
  #
  # Displays a search box for adding collaborators
  #
  def new
    @collaborator = CookbookCollaborator.new
    render layout: false
  end

  #
  # POST /cookbooks/:cookbook_id/collaborators
  #
  # Add a collaborator to a cookbook.
  #
  def create
    authorize!(@cookbook, :create_collaborator?)
    collaborator_params = params.require(:cookbook_collaborator).permit(:user_id)
    users = eligible_collaborators.where(id: collaborator_params[:user_id].split(','))

    users.each do |user|
      cookbook_collaborator = CookbookCollaborator.create! cookbook: @cookbook, user: user
      CollaboratorMailer.delay.added_email(cookbook_collaborator)
    end

    redirect_to cookbook_path(@cookbook), notice: 'Collaborators added'
  end

  #
  # DELETE /cookbooks/:cookbook_id/collaborators/:id
  #
  # Remove a single collaborator.
  #
  def destroy
    respond_to do |format|
      format.js do
        user = User.find(params[:id])
        cookbook_collaborator = CookbookCollaborator.with_cookbook_and_user(@cookbook, user)

        if cookbook_collaborator.nil?
          head :not_found
        else
          authorize!(cookbook_collaborator)
          cookbook_collaborator.destroy
          head :ok
        end
      end
    end
  end

  private

  #
  # Find a cookbook from the +cookbook_id+ param
  #
  # @return [Cookbook]
  #
  def find_cookbook
    @cookbook = Cookbook.with_name(params[:cookbook_id]).first!
  end

  #
  # Finds eligible collaborators, namely users that are not the cookbook owner
  # and are not already collaborators
  #
  # @return [Array<User>]
  #
  def eligible_collaborators
    ineligible_users = [@cookbook.collaborators, @cookbook.owner].flatten
    User.where('users.id NOT IN (?)', ineligible_users)
  end
end
