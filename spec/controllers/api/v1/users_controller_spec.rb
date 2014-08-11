require 'spec_helper'

describe Api::V1::UsersController do
  let!(:user) { create(:user) }

  let!(:redis_test) do
    create(:cookbook, name: 'redis_test', owner: user)
  end

  let!(:macand) do
    create(:cookbook, name: 'macand', owner: user)
  end

  let!(:zeromq) { create(:cookbook, name: 'zeromq') }
  let!(:apples) { create(:cookbook, name: 'apples') }
  let!(:postgres) { create(:cookbook, name: 'postgres') }
  let!(:ruby) { create(:cookbook, name: 'ruby') }

  describe '#show' do
    context 'when a user exists' do
      before do
        create(
          :account,
          provider: 'chef_oauth2',
          user: user,
          username: 'clive'
        )
        create(
          :account,
          provider: 'github',
          user: user,
          username: 'clive'
        )
        create(
          :account,
          provider: 'github',
          user: user,
          username: 'xanadu'
        )
        create(
          :cookbook_collaborator,
          resourceable: zeromq,
          user: user
        )
        create(
          :cookbook_collaborator,
          resourceable: apples,
          user: user
        )
        create(
          :cookbook_follower,
          cookbook: postgres,
          user: user
        )
        create(
          :cookbook_follower,
          cookbook: ruby,
          user: user
        )
      end

      it 'responds with a 200' do
        get :show, user: 'clive', format: :json

        expect(response.status.to_i).to eql(200)
      end

      it 'sends the user to the view' do
        get :show, user: 'clive', format: :json

        expect(assigns[:user]).to eql(user)
      end

      it "sends the user's github accounts to the view" do
        get :show, user: 'clive', format: :json

        expect(assigns[:github_usernames]).to include('clive')
        expect(assigns[:github_usernames]).to include('xanadu')
      end

      it 'sorts the github accounts by username' do
        get :show, user: 'clive', format: :json

        expect(assigns[:github_usernames]).to eql(%w(clive xanadu))
      end

      it 'sends the owned cookbooks to the view' do
        get :show, user: 'clive', format: :json

        expect(assigns[:owned_cookbooks]).to include(macand)
        expect(assigns[:owned_cookbooks]).to include(redis_test)
      end

      it 'sorts the owned cookbooks by name' do
        get :show, user: 'clive', format: :json

        expect(assigns[:owned_cookbooks].to_a).to eql([macand, redis_test])
      end

      it 'sends the collaborated cookbooks to the view' do
        get :show, user: 'clive', format: :json

        expect(assigns[:collaborated_cookbooks]).to include(apples)
        expect(assigns[:collaborated_cookbooks]).to include(zeromq)
      end

      it 'sorts the collaborated cookbooks by name' do
        get :show, user: 'clive', format: :json

        expect(assigns[:collaborated_cookbooks].to_a).to eql([apples, zeromq])
      end

      it 'sends the followed cookbooks to the view' do
        get :show, user: 'clive', format: :json

        expect(assigns[:followed_cookbooks]).to include(ruby)
        expect(assigns[:followed_cookbooks]).to include(postgres)
      end

      it 'sorts the followed cookbooks by name' do
        get :show, user: 'clive', format: :json

        expect(assigns[:followed_cookbooks].to_a).to eql([postgres, ruby])
      end

    end

    context 'when a user does not exist' do
      it 'responds with a 404' do
        get :show, user: 'sushiqueen', format: :json

        expect(response.status.to_i).to eql(404)
      end
    end
  end
end
