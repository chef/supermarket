require 'spec_helper'

describe ApplicationController do
  it { should be_a(Supermarket::Authorization) }
  it { should be_a(Supermarket::LocationStorage) }

  describe 'when a controller does not respond to the given format' do
    controller do
      def index
        respond_to do |format|
          format.json do
            render json: {}
          end
        end
      end
    end

    it '404s' do
      get :index

      expect(response).to render_template('exceptions/404')
      expect(response.status.to_i).to eql(404)
    end
  end
end
