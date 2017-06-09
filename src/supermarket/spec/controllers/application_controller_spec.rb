require 'spec_helper'

describe ApplicationController do
  it { should be_a(Supermarket::Authorization) }
  it { should be_a(Supermarket::LocationStorage) }

  describe 'a controller which responds to specific formats' do
    controller do
      def index
        respond_to do |format|
          format.json do
            render json: {}
          end
        end
      end

      def show
        respond_to do |format|
          format.html do
            render text: ''
          end
        end
      end

      def edit; end
    end

    it '404s when HTML is requested by JSON is served' do
      get :index

      expect(response.status.to_i).to eql(404)
    end

    it '404s when JSON is requested but HTML is served' do
      get :show, params: { id: 1, format: :json }

      expect(response.status.to_i).to eql(404)
    end

    it 'sets the default search context as cookbooks' do
      get :index

      expect(assigns[:search][:name]).to eql('Cookbooks')
      expect(assigns[:search][:path]).to eql(cookbooks_path)
    end
  end

  describe 'github integration' do
    before { Feature.deactivate(:github) }
    after { Feature.activate(:github) }

    controller do
      before_action :require_linked_github_account!

      def index
        respond_to do |format|
          format.html do
            render plain: 'haha'
          end
        end
      end

      def current_user
        nil
      end
    end

    it 'skips the require_linked_github_account! filter if github integration is disabled' do
      get :index

      expect(response).to be_success
      expect(response.body).to eql('haha')
    end
  end
end
