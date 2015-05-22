require 'spec_helper'

describe MakeUserAdmin do

  context "finding the user" do
    let(:user) { create(:user) }

    it "searches for the user" do
      expect(User).to receive(:find).and_return(user)
      MakeUserAdmin.new(user)
    end

    context "when it exists" do
      let(:make_user_admin) { MakeUserAdmin.new(user) }

      before do
        allow(User).to receive(:find).and_return(user)
      end

      it "assigns the correct user" do
        expect(make_user_admin.user).to eq(user)
      end
    end

    context "when it does not exist" do
      it "returns an error"
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
