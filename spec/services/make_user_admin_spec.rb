require 'spec_helper'

describe MakeUserAdmin do
  let(:user) { create(:user) }
  let(:make_user_admin) { MakeUserAdmin.new(user) }

  context "finding the user" do
    it "searches for the user" do
      expect(User).to receive(:find).and_return(user)
      make_user_admin.call
    end

    context "when it does not exist" do
      before do
        allow(User).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it "returns an error" do
        expect(make_user_admin.call).to include("User not found in Supermarket")
      end
    end
  end

  context "promoting the user to admin" do
    let(:roles) { user.roles }

    before do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:roles).and_return(roles)
    end

    context "when successful" do
      it "adds the admin role" do
        expect(user.roles).to receive(:push).with('admin')
        make_user_admin.call
      end

      it "saves the user" do
        expect(user).to receive(:save)
        make_user_admin.call
      end

      it "returns a success message" do
        expect(make_user_admin.call).to include("#{user.username} has been promoted to Admin!")
      end
    end

    context "when not successful" do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it "returns an error" do
        expect(make_user_admin.call).to include("#{user.username} was not able to be promoted to Admin at this time.  Please try again later.")
      end
    end
  end

end
