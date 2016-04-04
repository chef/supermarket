module GroupsHelper
  def admin_member?(user, group)
    group.group_members.where(user_id: user.id, admin: true).present?
  end

  def admin_members(group)
    group.group_members.where(admin: true)
  end

  def group_resourceables(group)
    resourceables = []
    group.group_resources.each do |resource|
      resourceables << resource.resourceable_type.constantize.find(resource.resourceable_id)
    end

    resourceables
  end
end
