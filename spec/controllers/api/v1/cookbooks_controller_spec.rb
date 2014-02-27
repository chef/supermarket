require 'spec_helper'

describe Api::V1::CookbooksController do

  let!(:slow_cooking) do
    create(:cookbook, name: 'slow_cooking')
  end

  let!(:sashimi) do
    create(:cookbook, name: 'sashimi')
  end

  describe '#index' do

    it 'orders the cookbooks by their name' do
      get :index, format: :json

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(['sashimi', 'slow_cooking'])
    end

    it 'uses the start param to offset the cookbooks sent to the view' do
      get :index, start: 1, format: :json

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(['slow_cooking'])
    end

    it 'passes the start param to the view' do
      get :index, start: 1, format: :json

      expect(assigns[:start]).to eql(1)
    end

    it 'defaults the start param to 0' do
      get :index, format: :json

      expect(assigns[:start]).to eql(0)
    end

    it 'uses the items param to limit the cookbooks sent to the view' do
      get :index, items: 1, format: :json

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(['sashimi'])
    end

    it 'defaults the items param to 10' do
      get :index, format: :json

      expect(assigns[:items]).to eql(10)
    end

    it 'limits the number of items to 100' do
      get :index, items: 101, format: :json

      expect(assigns[:items]).to eql(100)
    end

    it 'handles the start and items param' do
      get :index, items: 1, start: 1, format: :json

      cookbook_names = assigns[:cookbooks].map(&:name)

      expect(cookbook_names).to eql(['slow_cooking'])
    end

    it 'passes the total number of cookbooks to the view' do
      get :index, format: :json

      expect(assigns[:total]).to eql(2)
    end
  end

  describe '#show' do
    context 'when a cookbook exists' do
      it 'responds with a 200' do
        get :show, cookbook: 'sashimi', format: :json

        expect(response.status.to_i).to eql(200)
      end

      it 'sends the cookbook to the view' do
        get :show, cookbook: 'sashimi', format: :json

        expect(assigns[:cookbook]).to eql(sashimi)
      end
    end

    context 'when a cookbook does not exist' do
      it 'responds with a 404' do
        get :show, cookbook: 'mamimi', format: :json

        expect(response.status.to_i).to eql(404)
      end
    end
  end
end
