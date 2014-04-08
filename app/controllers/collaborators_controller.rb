class CollaboratorsController < ApplicationController
  before_filter :find_cookbook_and_user, only: [:create, :destroy]

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
  # POST /cookbooks/:cookbook_id/collaborators/:id
  #
  # Add a collaborator to a cookbook.
  #
  def create
    CookbookCollaborator.create! cookbook: @cookbook, user: @user

    respond_to do |format|
      format.json
    end
  end

  #
  # DELETE /cookbooks/:cookbook_id/collaborators/:id
  #
  # Remove a single collaborator.
  #
  def destroy
    cc = CookbookCollaborator.with_cookbook_and_user(@cookbook, @user)

    respond_to do |format|
      format.json do
        if cc
          render
        else
          head 404
        end
      end
    end
  end

  private

  def find_cookbook
    @cookbook = Cookbook.find(params[:cookbook_id])
    @user = User.find(params[:id])
  end
end
