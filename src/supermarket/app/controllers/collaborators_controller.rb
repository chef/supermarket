class CollaboratorsController < ApplicationController
  include CollaboratorProcessing

  before_action :authenticate_user!
  before_action :find_collaborator, only: [:destroy, :transfer]
  skip_before_action :verify_authenticity_token, only: [:destroy]

  #
  # GET /collaborators?q=jimmy&ineligible_user_ids=[1,2,3]
  #
  # Searches for someone by username, limited to potential collaborators or owners
  # for a given resource.
  #
  def index
    @collaborators = User
      .includes(:chef_account)
      .where.not(id: params[:ineligible_user_ids])
      .limit(20)

    if params[:q]
      @collaborators = @collaborators.search(params[:q])
    end

    respond_to do |format|
      format.json
    end
  end

  #
  # POST /collaborators
  #
  # Add a collaborator to a resource.
  #
  def create
    resourceable_type = collaborator_params[:resourceable_type]
    RESOURCEABLE_MODELS = {
      "Cookbook" => Cookbook,
      "Tool" => Tool
    }
    if RESOURCEABLE_MODELS.key?(resourceable_type)
      resourceable_klass = RESOURCEABLE_MODELS[resourceable_type]
      resource = resourceable_klass.find(
        collaborator_params[:resourceable_id]
      )

      add_users_as_collaborators(resource, collaborator_params[:user_ids]) if collaborator_params[:user_ids].present?

      add_group_members_as_collaborators(resource, collaborator_params[:group_ids]) if collaborator_params[:group_ids].present?

      if resource.class == Cookbook
        perform_fieri(resource)
      end

      redirect_to resource, notice: t("collaborator.added")
    else
      not_found!
    end
  end

  #
  # DELETE /collaborators/:id
  #
  # Remove a single collaborator or group of collaborators
  #
  def destroy
    respond_to do |format|
      format.js do
        remove_collaborator(@collaborator)
        head 200
      end
    end
  end

  # DELETE /collaborators/:id/destroy_group
  # id is group's id
  #
  # Removes a group of collaborators
  #
  def destroy_group
    group = Group.find(params[:id])

    if %w{Cookbook Tool}.include?(params[:resourceable_type])
      resource = params[:resourceable_type].constantize.find(
        params[:resourceable_id]
      )

      collaborator_users = group_collaborators(resource, group).map(&:user)

      remove_group_collaborators(group_collaborators(resource, group))

      GroupResource.where(group: group, resourceable: resource).each(&:destroy)

      flash[:notice] = t("collaborator.group_removed", name: group.name) + " "

      dup_user_collaborators(collaborator_users, resource).each do |collaborator|
        flash[:notice] << if collaborator.group.present?
                            "#{collaborator.user.username} is still a collaborator associated with #{collaborator.group.name}" + " "
                          else
                            "#{collaborator.user.username} is still a collaborator on this #{params[:resourceable_type]}" " "
                          end
      end
      resource_path_str = "#{params[:resourceable_type].underscore}_path"
      redirect_to(
        send(resource_path_str, resource)
      )
    else
      not_found!
    end
  end

  #
  # PUT /collaborators/:id/transfer
  #
  # Transfers ownership of the resource to a collaborator, thereby demoting the
  # owner to a collaborator.
  #
  def transfer
    authorize!(@collaborator)

    @collaborator.transfer_ownership

    redirect_to(
      @collaborator.resourceable,
      notice: t("collaborator.owner_changed",
                resource: @collaborator.resourceable.name,
                user: @collaborator.user.username)
    )
  end

  private

  #
  # Find the CookbookCollaborator from an existing Cookbook and User
  #
  # @return [CookbookCollaborator]
  #
  def find_collaborator
    @collaborator = Collaborator.find(params[:id])
  end

  #
  # Check if Fieri features are active and run Fieri
  #
  def perform_fieri(cookbook)
    if Feature.active?(:fieri) && ENV["FIERI_URL"].present?
      FieriNotifyWorker.perform_async(
        cookbook.latest_cookbook_version.id
      )
    end
  end

  #
  # Params used when creating one or more +Collaborator+.
  #
  def collaborator_params
    params
      .require(:collaborator)
      .permit(:resourceable_type,
              :resourceable_id,
              :user_ids,
              :group_ids)
  end

  def group_collaborators(resource, group)
    Collaborator.where(resourceable: resource, group: group)
  end

  def dup_user_collaborators(collaborator_users, resource)
    dup_user_collaborators = []

    collaborator_users.each do |user|
      resource.collaborators.where(user: user).each do |dup_user|
        dup_user_collaborators << dup_user
      end
    end

    dup_user_collaborators
  end
end
