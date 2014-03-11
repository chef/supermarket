require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  context 'the user provides valid params' do
    let(:payload) { fixture_file_upload('spec/support/cookbook_fixtures/redis-test-v1.tgz', 'application/x-gzip') }
    let!(:category) { create(:category, name: 'Databases') }

    it 'returns a 201' do
      post '/api/v1/cookbooks', cookbook: '{"category": "databases"}', tarball: payload
      expect(response.status.to_i).to eql(201)
    end

    it 'returns the URI for the newly created cookbook' do
      post '/api/v1/cookbooks', cookbook: '{"category": "databases"}', tarball: payload
      expect(json_body['uri']).to match(%r(api/v1/cookbooks/redis))
    end
  end

  context "the user doesn't provide valid params" do
    let(:payload) { fixture_file_upload('spec/support/cookbook_fixtures/redis-test-v1.tgz', 'application/x-gzip') }
    before(:each) { post '/api/v1/cookbooks', tarball: payload }

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
