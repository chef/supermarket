class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_cookbook
  before_filter :find_user, only: [:destroy, :transfer]
  before_filter :find_cookbook_collaborator, only: [:destroy, :transfer]
  skip_before_filter :verify_authenticity_token, only: [:destroy]

  #
  # GET /cookbooks/:cookbook_id/collaborators?q=jimmy
  #
  # Searches for someone by username, either potential collaborators or owners.
  #
  def index
    if params[:include_collaborators].present?
      @collaborators = eligible_owners.limit(20)
    else
      @collaborators = eligible_collaborators.limit(20)
    end

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
        if @cookbook_collaborator.nil?
          head :not_found
        else
          authorize!(@cookbook_collaborator)
          @cookbook_collaborator.destroy
          head :ok
        end
      end
    end
  end

  #
  # PUT /cookbooks/:cookbook_id/collaborators/:id/transfer
  #
  # Transfers ownership of the cookbook to a collaborator, thereby demoting the
  # owner to a collaborator.
  #
  def transfer
    if @cookbook_collaborator.nil?
      not_found!
    else
      authorize!(@cookbook_collaborator)
      @cookbook_collaborator.transfer_ownership

      redirect_to cookbook_path(@cookbook), notice: 'Owner changed'
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
  # Find a user from the +id+ param
  #
  # @return [User]
  #
  def find_user
    @user = User.with_username(params[:id]).first
  end

  #
  # Find the CookbookCollaborator from an existing Cookbook and User
  #
  # @return [CookbookCollaborator]
  #
  def find_cookbook_collaborator
    @cookbook_collaborator = CookbookCollaborator.with_cookbook_and_user(@cookbook, @user)
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

  #
  # Finds eligible owners for cookbook ownership transfering,
  # any user that's not currently the owner.
  #
  # @return [Array<User>]
  #
  def eligible_owners
    User.where('users.id != ?', @cookbook.user_id)
  end
end
