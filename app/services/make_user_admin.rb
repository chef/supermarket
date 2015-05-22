class MakeUserAdmin
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    begin
      user = User.find(@user)
      add_admin_role(user)
    rescue ActiveRecord::RecordNotFound
      user_not_found_message
    end
  end

  private

  def user_not_found_message
    "User not found in Supermarket.  Make sure the user exists in Supermarket before making it an admin."
  end

  def successful_promotion_message(user)
    "#{user.username} has been promoted to Admin!"
  end

  def unsuccessful_promotion_message(user)
    "#{user.username} was not able to be promoted to Admin at this time.  Please try again later."
  end

  def add_admin_role(user)
    user.roles.push('admin')
    user.save ? successful_promotion_message(user) : unsuccessful_promotion_message(user)
  end

end
