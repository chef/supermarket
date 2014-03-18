require 'spec_helper'

describe CookbooksController do
  describe 'GET #index' do
    context 'there are no parameters' do
      it 'assigns @cookbooks' do
        get :index
        expect(assigns[:cookbooks]).to_not be_nil
      end
    end

    context 'there is an order parameter' do
      let!(:cookbook_1) { create(:cookbook, updated_at: 1.year.ago, created_at: 1.year.ago) }
      let!(:cookbook_2) { create(:cookbook, updated_at: 1.day.ago, created_at: 2.years.ago) }

      it 'orders @cookbooks by updated at' do
        get :index, order: 'updated_at'
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it 'orders @cookbooks by created at' do
        get :index, order: 'created_at'
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end
    end
  end

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
