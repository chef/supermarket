require 'spec_helper'

describe ContributorRequestsController do
  describe '#create' do
    before do
      request.env['HTTP_REFERER'] = '/'
    end

    it 'requires authentication' do
      ccla_signature = create(:ccla_signature)

      post :create, ccla_signature_id: ccla_signature.id

      expect(response).to redirect_to(sign_in_url)
    end
  end
end
