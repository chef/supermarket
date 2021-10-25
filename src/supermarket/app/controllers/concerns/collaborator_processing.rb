module CollaboratorProcessing
  extend ActiveSupport::Concern

  included do
    helper_method :add_users_as_collaborators
  end

  def add_users_as_collaborators(resource, user_ids, group_id = nil)
    # sometimes user_ids comes in as a string; need it to be an array
    user_ids = user_ids.split(",") if user_ids.class == String
    # unless users are coming in associated with a group, filter out users that
    # are already collaborators
    user_ids -= ineligible_ids(resource) unless group_id

    User.where(id: user_ids).each do |user|
      collaborator = Collaborator.new(
        user_id: user.id,
        resourceable: resource,
        group_id: group_id
      )

      # Passes object and action to Supermarket::Authorization,
      # which in turn passes them to Pundit for authorization
      authorize!(collaborator, "create?")

      collaborator.save!
      CollaboratorMailer.delay.added_email(collaborator)
    end
  end

  def add_group_members_as_collaborators(resource, group_ids)
    group_ids.split(",").each do |group_id|
      add_users_as_collaborators(resource, group_user_ids(group_id), group_id)
      associate_group_to_resource(group_id, resource)
    end
  end

  def remove_collaborator(collaborator)
    authorize!(collaborator, "destroy?")
    cookbook_related = nil

    if collaborator.resourceable_type == Collaborator::COOKBOOK_TYPE
      cookbook_related = Cookbook.find_by(id: collaborator.resourceable_id)
    end
    collaborator.destroy

    # get collaborator cookbook and run quality metrics
    if cookbook_related.present?
      if Feature.active?(:fieri) && ENV["FIERI_URL"].present?
        FieriNotifyWorker.perform_async(
          cookbook_related.latest_cookbook_version.id
        )
      end
    end
  end

  def remove_group_collaborators(collaborators)
    collaborators.each do |collaborator|
      remove_collaborator(collaborator)
    end
  end

  private

  def ineligible_ids(resource)
    if Collaborator.ineligible_collaborators_for(resource)
      Collaborator.ineligible_collaborators_for(resource).map(&:id).map(&:to_s)
    else
      []
    end
  end

  def group_user_ids(group)
    Group.find(group).members.map(&:id).map(&:to_s)
  end

  def associate_group_to_resource(group_id, resource)
    group = Group.find(group_id)
    group.group_resources << GroupResource.create!(group: group, resourceable: resource)
  end
end
