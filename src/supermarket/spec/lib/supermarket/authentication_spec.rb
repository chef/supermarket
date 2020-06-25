require "spec_helper"

describe Supermarket::Authentication do
  subject do
    Class.new(ApplicationController) do
      include Supermarket::Authentication
    end.new
  end

  describe "#current_user" do
    it "returns nil if there is no session" do
      allow(subject).to receive(:session).and_return({})
      expect(subject.current_user).to be_nil
    end

    it "finds the user by the session" do
      user = double(:user)
      allow(User).to receive(:find_by).with(id: 1).and_return(user)
      allow(subject).to receive(:session).and_return(user_id: 1)

      expect(subject.current_user).to be(user)
    end
  end

  describe "#signed_in?" do
    it "returns true when there is a current_user" do
      allow(subject).to receive(:current_user).and_return(true)
      expect(subject.signed_in?).to be true
    end

    it "returns false when there is no current_user" do
      allow(subject).to receive(:current_user).and_return(false)
      expect(subject.signed_in?).to be false
    end
  end
end
