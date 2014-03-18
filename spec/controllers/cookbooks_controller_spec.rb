require 'spec_helper'

describe CookbooksController do
  describe 'GET #directory' do
    before { get :directory }

    it 'assigns @recently_updated_cookbooks' do
      expect(assigns[:recently_updated_cookbooks]).to_not be_nil
    end

    it 'assigns @recently_created_cookbooks' do
      expect(assigns[:recently_created_cookbooks]).to_not be_nil
    end
  end
end
