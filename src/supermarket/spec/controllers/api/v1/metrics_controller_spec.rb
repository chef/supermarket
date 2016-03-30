require 'spec_helper'

describe Api::V1::MetricsController do
  describe '#show' do
    it 'retrieves metrics' do
      get :show, format: :json
      expect(response).to be_success
      expect(assigns(:metrics)).to_not be_nil
    end
  end
end
