class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :destroy]
  before_filter :find_cookbook, only: [:new, :create, :destroy]
  skip_before_filter :verify_authenticity_token, only: [:destroy]

  #
  # GET /collaborators?q=jimmy
  #
  # Searches for someone by username.
  #
  def index
    @collaborators = User.with_icla_signature.limit(20)

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
  end

  #
  # POST /cookbooks/:cookbook_id/collaborators
  #
  # Add a collaborator to a cookbook.
  #
  def create
    users = User.find(params[:cookbook_collaborator][:user_id].split(','))

    if users.present?
      users.each do |user|
        if can_modify_collaborators?(user)
          CookbookCollaborator.create cookbook: @cookbook, user: user
          # TODO send an email to user here
        end
      end
    end

    flash[:notice] = 'Collaborators added'
    redirect_to cookbook_path(@cookbook)
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

        if can_modify_collaborators?(user)
          cc = CookbookCollaborator.with_cookbook_and_user(@cookbook, user)

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

  #
  # Find a cookbook from the +cookbook_id+ param
  #
  # @return [Cookbook]
  #
  def find_cookbook
    @cookbook = Cookbook.with_name(params[:cookbook_id]).first!
  end

  #
  # Determine if the cookbook collaborators can be modified. Only the cookbook
  # owner or the collaborator in question can remove collaborators.
  #
  # @return [Boolean] Whether the modification is legal
  #
  def can_modify_collaborators?(user)
    @cookbook.owner == current_user ||
      (@cookbook.collaborators.include?(user) && user == current_user)
  end
end
