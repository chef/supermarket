class MakeUserAdmin
  def initialize(user_name)
    @user_name = user_name
  end

  def call
    user = User.with_username(@user_name).first
    user.present? ? add_admin_role(user) : user_not_found_message(@user_name)
  end

  private

  def user_not_found_message(user_name)
    I18n.t('user.not_found', name: user_name)
  end

  def successful_promotion_message(user)
    I18n.t('user.successful_promotion_message', name: user.username)
  end

  def unsuccessful_promotion_message(user)
    I18n.t('user.unsuccessful_promotion_message', name: user.username)
  end

  def user_already_admin_message(user)
    I18n.t('user.already_admin', name: user.username)
  end

  def add_admin_role(user)
    return user_already_admin_message(user) if user.roles.include?('admin')

    user.roles = user.roles + ['admin']
    user.save ? successful_promotion_message(user) : unsuccessful_promotion_message(user)
  end
end
