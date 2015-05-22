class MakeUserAdmin
  attr_accessor :user

  def initialize(user)
    @user = find_user(user)
  end

  private

  def find_user(user)
    User.find(user)
  end
end
