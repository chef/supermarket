require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  context 'the user provides valid params' do
    before(:each) { share_cookbook }

    it 'returns a 201' do
      expect(response.status.to_i).to eql(201)
    end

    it 'returns the URI for the newly created cookbook' do
      expect(json_body['uri']).to match(%r(api/v1/cookbooks/redis))
    end
  end

  context "the user doesn't provide valid params" do
    before(:each) { post '/api/v1/cookbooks', category: 'other' }

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns a error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns a corresponding error message' do
      expect(json_body['error_messages']).to_not be_nil
    end
  end
end
