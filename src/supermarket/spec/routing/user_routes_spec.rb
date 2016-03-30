require 'spec_helper'

describe 'user routes' do
  context 'to show a user' do
    it 'uses the Chef Account username as the id parameter' do
      # NOTE: if this fails, be sure to update
      # app/views/contributors/index.html.erb, which uses the optimized user
      # route helper
      user = create(:user)

      typical_user_route = user_path(user)
      optimized_user_route = user_path(id: user.chef_account.username)

      expect(typical_user_route).to eql(optimized_user_route)
    end
  end
end
