module AuthHelpers
  def sign_in(user)
    allow(subject).to receive(:current_user) { user }
  end

  def sign_out
    allow(subject).to receive(:current_user) { nil }
  end
end
