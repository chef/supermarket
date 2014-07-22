require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  let(:user) { create(:user) }

  context 'the user provides valid params' do
    before(:each) { share_cookbook('redis-test', user) }

    it 'returns a 201' do
      expect(response.status.to_i).to eql(201)
    end

    it 'returns the URI for the newly created cookbook' do
      expect(json_body['uri']).to match(%r{api/v1/cookbooks/redis})
    end
  end

  context "the user doesn't provide valid params" do
    before(:each) { share_cookbook('redis-test', user, payload: {}) }

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns an error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns a error message' do
      expect(json_body['error_messages']).to_not be_nil
    end
  end

  context "the user sharing doesn't exist" do
    before(:each) { share_cookbook('redis-test', double('user', username: 'invalid-user')) }

    it 'returns a 401' do
      expect(response.status.to_i).to eql(401)
    end

    it 'returns an error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns an error message' do
      expect(json_body['error_messages']).to_not be_nil
    end
  end

  context 'the users private/public key pair is invalid' do
    before(:each) { share_cookbook('redis-test', user, with_invalid_private_key: true) }

    it 'returns a 401' do
      expect(response.status.to_i).to eql(401)
    end

    it 'returns an error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns an error message' do
      expect(json_body['error_messages']).to_not be_nil
    end
  end

  context 'the user is a fresh import from the existing community site' do
    let(:imported_user) { create(:user, public_key: nil) }

    before { share_cookbook('redis-test', imported_user) }

    it 'returns a 401' do
      expect(response.status.to_i).to eql(401)
    end

    it 'returns an error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns an error message' do
      expect(json_body['error_messages']).to_not be_nil
    end
  end

  context 'invalid content type headers are sent' do
    it 'returns a descriptive error' do
      share_cookbook('redis-test', user, content_type: 'application/snarfle')
      expect(json_body['error_messages'].first).to eql('Tarball content type can not be application/snarfle.')
    end
  end

  context 'invalid signing headers are sent' do
    before(:each) { share_cookbook('redis-test', user, omitted_headers: ['X-Ops-Sign']) }

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns an error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns an error message' do
      expect(json_body['error_messages']).to_not be_nil
    end
  end
end
