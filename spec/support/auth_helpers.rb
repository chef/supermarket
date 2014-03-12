module AuthHelpers
  def sign_in(user)
    subject.stub(:current_user) { user }
  end

  def sign_out
    subject.stub(:current_user) { nil }
  end
end
