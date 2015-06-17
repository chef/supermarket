require 'spec_helper'

describe MakeUserAdmin do
  let(:user) { create(:user) }
  let(:make_user_admin) { MakeUserAdmin.new(user.username) }

  context 'finding the user' do
    it 'searches for the user by the username' do
      expect(User).to receive(:with_username).with(user.username).and_return([user])
      make_user_admin.call
    end

    context 'when it does not exist' do
      before do
        allow(User).to receive(:with_username).and_return([])
      end

      it 'returns an error' do
        expect(make_user_admin.call).to include("#{user.username} was not found in Supermarket")
      end
    end
  end

  context 'promoting the user to admin' do
    before do
      allow(User).to receive(:with_username).and_return([user])
    end

    context 'when successful' do
      it 'saves the user' do
        expect(user).to receive(:save)
        make_user_admin.call
      end

      it 'returns a success message' do
        expect(make_user_admin.call).to include("#{user.username} has been made an admin!")
      end

      it 'adds the admin role to the user' do
        expect(user.roles).to_not include('admin')
        make_user_admin = MakeUserAdmin.new(user.username)
        make_user_admin.call
        user.reload
        expect(user.roles).to include('admin')
      end
    end

    context 'when not successful' do
      before do
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:save).and_return(false)
      end

      it 'returns an error' do
        expect(make_user_admin.call).to include("#{user.username} was not able to be promoted to an admin at this time.  Please try again later.")
      end
    end

    context 'when the user is already an admin' do
      before do
        user.roles = user.roles + ['admin']
        user.save!
        expect(user.roles).to include('admin')
      end

      it 'returns a message' do
        make_user_admin = MakeUserAdmin.new(user.username)
        expect(make_user_admin.call).to include("#{user.username} is already an admin.")
      end
    end
  end
end
