class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :destroy]
  before_filter :find_cookbook, only: [:new, :create, :destroy]
  before_filter :find_user, only: [:create, :destroy]

  #
  # GET /collaborators?q=jimmy
  #
  # Searches for someone by username.
  #
  def index
    if params[:q]
      @collaborators = User.search(params[:q])
    else
      @collaborators = User.all
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
  end

  #
  # POST /cookbooks/:cookbook_id/collaborators/:user_id
  #
  # Add a collaborator to a cookbook.
  #
  def create
    respond_to do |format|
      format.json do
        if cookbook_ownership_valid?
          CookbookCollaborator.create! cookbook: @cookbook, user: @user
        else
          head :forbidden
        end
      end
    end
  end

  #
  # DELETE /cookbooks/:cookbook_id/collaborators/:user_id
  #
  # Remove a single collaborator.
  #
  def destroy
    respond_to do |format|
      format.json do
        if cookbook_ownership_valid?
          cc = CookbookCollaborator.with_cookbook_and_user(@cookbook, @user)

          if cc.nil?
            head :not_found
          else
            cc.destroy
            head :ok
          end
        else
          head :forbidden
        end
      end
    end
  end

  private

  # TODO document this jazz
  def find_cookbook
    @cookbook = Cookbook.with_name(params[:cookbook_id]).first!
  end

  def find_user
    @user = User.find(params[:user_id])
  end

  def cookbook_ownership_valid?
    @cookbook.owner == current_user ||
      (@cookbook.collaborators.include?(@user) && @user == current_user)
  end
end
