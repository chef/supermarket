class MakeUserAdmin
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call
    begin
      User.find(@user)
    rescue ActiveRecord::RecordNotFound
      "User not found in Supermarket.  Make sure the user exists in Supermarket before making it an admin."
    end
  end

end
