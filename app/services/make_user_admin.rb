class MakeUserAdmin
  def initialize(user_name)
    @user_name = user_name
  end

  def call
    user = User.with_username(@user_name).first
    user.present? ? add_admin_role(user) : user_not_found_message
  end

  private

  def user_not_found_message
    'User not found in Supermarket.  Make sure the user exists in Supermarket before making it an admin.'
  end

  def successful_promotion_message(user)
    "#{user.username} has been promoted to Admin!"
  end

  def unsuccessful_promotion_message(user)
    "#{user.username} was not able to be promoted to Admin at this time.  Please try again later."
  end

  def add_admin_role(user)
    user.roles = user.roles + ['admin']
    user.save ? successful_promotion_message(user) : unsuccessful_promotion_message(user)
  end
end
