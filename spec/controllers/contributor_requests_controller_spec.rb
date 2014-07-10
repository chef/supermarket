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

    it '404s if the given CCLA Signature does not exist' do
      sign_in(create(:user))

      post :create, ccla_signature_id: -1

      expect(response.code.to_i).to eql(404)
    end

    it 'does not allow existing contributors to make requests' do
      contributing_user = create(:user)
      ccla_signature = create(:ccla_signature)
      create(
        :contributor,
        organization: ccla_signature.organization,
        user: contributing_user
      )

      sign_in(contributing_user)

      post :create, ccla_signature_id: ccla_signature.id

      expect(response).to render_template('exceptions/404')
    end
  end
end
