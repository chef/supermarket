require 'spec_helper'

describe MakeUserAdmin do

  context "finding the user" do
    let(:user) { create(:user) }
    let(:make_user_admin) { MakeUserAdmin.new(user) }

    it "searches for the user" do
      expect(User).to receive(:find).and_return(user)
      make_user_admin.call
    end

    context "when it exists" do
      let(:make_user_admin) { MakeUserAdmin.new(user) }

      before do
        allow(User).to receive(:find).and_return(user)
      end

      it "assigns the correct user"
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
    context "when successful" do
      it "adds the admin role"

      it "saves the user"
    end

    context "when not successful" do
      it "returns an error"
    end
  end

end
