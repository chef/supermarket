require 'spec_helper'

describe CookbooksController do
  describe 'GET #index' do
    it 'assigns @recently_updated_cookbooks' do
      get :index

      expect(assigns[:recently_updated_cookbooks]).to_not be_nil
    end
  end
end
