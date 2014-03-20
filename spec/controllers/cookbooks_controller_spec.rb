require 'spec_helper'

describe CookbooksController do
  describe 'GET #index' do
    context 'there are no parameters' do
      it 'assigns @cookbooks' do
        get :index
        expect(assigns[:cookbooks]).to_not be_nil
      end

      it 'paginates @cookbooks' do
        create_list(:cookbook, 30)
        get :index

        expect(assigns[:cookbooks].count).to eql(20)
      end

      it 'assigns @categories' do
        get :index
        expect(assigns[:categories]).to_not be_nil
      end
    end

    context 'there is an order parameter' do
      let!(:cookbook_1) { create(:cookbook, updated_at: 1.year.ago, created_at: 1.year.ago) }
      let!(:cookbook_2) { create(:cookbook, updated_at: 1.day.ago, created_at: 2.years.ago) }

      it 'orders @cookbooks by updated at' do
        get :index, order: 'recently_updated'
        expect(assigns[:cookbooks].first).to eql(cookbook_2)
      end

      it 'orders @cookbooks by created at' do
        get :index, order: 'created_at'
        expect(assigns[:cookbooks].first).to eql(cookbook_1)
      end
    end

    context 'there is a category parameter' do
      let!(:databases_cookbook) { create(:cookbook, category: create(:category, name: 'Databases')) }
      let!(:other_cookbook) { create(:cookbook, category: create(:category, name: 'Other')) }

      it 'only returns @cookbooks with the specified category' do
        get :index, category: 'other'

        expect(assigns[:cookbooks]).to include(other_cookbook)
        expect(assigns[:cookbooks]).to_not include(databases_cookbook)
      end
    end

    context 'there is a query parameter' do
      let!(:amazing_cookbook) do
        create(
          :cookbook,
          name: 'Amazing Cookbook',
          maintainer: 'john@example.com',
          description: 'Makes you a pirate',
          category: create(:category, name: 'Databases')
        )
      end

      let!(:ok_cookbook) do
        create(
          :cookbook,
          name: 'OK Cookbook',
          maintainer: 'jack@example.com',
          description: 'Makes you a pigeon',
          category: create(:category, name: 'Other')
        )
      end

      it 'only returns @cookbooks that match the name' do
        get :index, q: 'amazing'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end

      it 'only returns @cookbooks that match the maintainer' do
        get :index, q: 'john'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end

      it 'only returns @cookbooks that match the description' do
        get :index, q: 'pirate'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end

      it 'only returns @cookbooks that match the category' do
        get :index, q: 'databases'

        expect(assigns[:cookbooks]).to include(amazing_cookbook)
        expect(assigns[:cookbooks]).to_not include(ok_cookbook)
      end
    end
  end

  describe 'GET #directory' do
    before { get :directory }

    it 'assigns @recently_updated_cookbooks' do
      expect(assigns[:recently_updated_cookbooks]).to_not be_nil
    end

    it 'assigns @recently_added_cookbooks' do
      expect(assigns[:recently_added_cookbooks]).to_not be_nil
    end

    it 'assigns @categories' do
      expect(assigns[:categories]).to_not be_nil
    end
  end
end
