class GroupsController < ApplicationController
  before_action :collaborator_groups_feature_check

  def index
    @groups = Group.all

    if params[:q]
      @groups = @groups.search(params[:q])
    end

    respond_to do |format|
      format.json
    end
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      GroupMember.create!(user: current_user, group: @group, admin: true)
      flash[:notice] = 'Group successfully created!'
      redirect_to group_path(@group)
    else
      flash[:warning] = "An error has occurred #{@group.errors.full_messages.join(', ')}"
      redirect_to new_group_path
    end
  end

  def show
    @group = Group.find(params[:id])
    @admin_members = @group.group_members.where(admin: true)
    @members = @group.group_members.where(admin: nil)
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def collaborator_groups_feature_check
    unless Feature.active?(:collaborator_groups)
      flash[:warning] = 'You must activate the collaborator_groups feature to create a group'
      redirect_to new_group_path
    end
  end
end
