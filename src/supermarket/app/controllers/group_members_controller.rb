class GroupMembersController < ApplicationController
  include CollaboratorProcessing

  before_action :find_group_member, only: [:destroy, :make_admin]
  before_action :check_admin_member_present, only: :destroy

  def create
    if group_member_params[:user_ids].present?
      user_ids = group_member_params[:user_ids].split(',')
    else
      flash[:warning] = 'At least one user must be added!'
      redirect_to group_path(group_member_params[:group_id])
    end

    if user_ids.present?
      user_ids.each do |user_id|
        group_member = GroupMember.new(
          user_id: user_id,
          group_id: group_member_params[:group_id]
        )
        if group_member.save
          group_resources(group_member).each do |resource|
            add_users_as_collaborators(resource, group_member.user.id.to_s, group_member.group.id)
          end
        else
          (flash[:warning] ||= '') << group_member.errors.full_messages.join(', ')
          return
        end
      end
      flash[:notice] = 'Members successfully added!'
      redirect_to group_path(group_member_params[:group_id])
    end
  end

  def destroy
    if @group_member.destroy
      group_resources(@group_member).each do |resource|
        collaborator = resource.collaborators.where(user_id: @group_member.user_id).first
        remove_collaborator(collaborator) if collaborator.present?
      end

      flash[:notice] = 'Member successfully removed'
    else
      flash[:warning] = 'An error has occurred'
    end
    redirect_to group_path(@group_member.group)
  end

  def make_admin
    if current_user_admin?
      @group_member.admin = true
      @group_member.save
      flash[:notice] = 'Member has successfully been made an admin!'
    else
      flash[:error] = 'You must be an admin member of the group to do that.'
    end

    redirect_to group_path(@group_member.group)
  end

  private

  def group_member_params
    params.require(:group_member).permit(:user_id, :group_id, :user_ids)
  end

  def current_user_admin?
    @group_member.group.group_members.where(user_id: current_user.id, admin: true).present?
  end

  def group_resources(group_member)
    group_member.group.group_resources.map(&:resourceable)
  end

  def find_group_member
    @group_member = GroupMember.find(params[:id])
  end

  def check_admin_member_present
    if @group_member.admin?
      unless @group_member.group.group_members.where(admin: true).count > 1
        flash[:warning] = 'Member could not be removed because a group must have at least one admin member'
        redirect_to group_path(@group_member.group)
      end
    end
  end
end
