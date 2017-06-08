class GrantBadgeToCookbook
  attr_reader :badge_name, :cookbook_name

  def initialize(badge:, cookbook:)
    @badge_name = badge
    @cookbook_name = cookbook
  end

  def call
    cookbook = Cookbook.find_by(name: cookbook_name)
    cookbook.present? ? add_badge_to_cookbook(cookbook) : cookbook_not_found_message
  end

  private

  def cookbook_not_found_message
    I18n.t('cookbook.not_found', name: cookbook_name)
  end

  def successful_grant_message
    I18n.t('badge.successful_grant_message', name: badge_name, grantee: cookbook_name)
  end

  def unsuccessful_grant_message
    I18n.t('badge.unsuccessful_grant_message', name: badge_name, grantee: cookbook_name)
  end

  def badge_is_not_valid
    I18n.t('badge.not_a_valid_badge_name', name: badge_name)
  end

  def cookbook_already_has_badge
    I18n.t('badge.already_granted', name: badge_name, grantee: cookbook_name)
  end

  def add_badge_to_cookbook(cookbook)
    return badge_is_not_valid unless Badgeable::BADGES.include? badge_name.to_s
    return cookbook_already_has_badge if cookbook.is? badge_name

    cookbook.badges += [badge_name]
    cookbook.save ? successful_grant_message : unsuccessful_grant_message
  end
end
