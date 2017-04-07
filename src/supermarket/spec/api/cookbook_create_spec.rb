require 'spec_helper'

describe 'POST /api/v1/cookbooks' do
  let(:user) { create(:user) }

  shared_context 'invalid cookbook' do
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

  shared_context 'valid cookbook' do
    it 'returns a 201' do
      expect(response.status.to_i).to eql(201)
    end

    it 'returns the URI for the newly created cookbook' do
      expect(json_body['uri']).to match(%r{api/v1/cookbooks/redis})
    end
  end

  context 'the user provides valid params' do
    before(:each) { share_cookbook('redis-test', user) }

    it_behaves_like 'valid cookbook'
  end

  context 'no category is given' do
    before(:each) { share_cookbook('redis-test', user, category: nil) }

    it_behaves_like 'valid cookbook'
  end

  context "the user doesn't provide valid params" do
    before(:each) { share_cookbook('redis-test', user, payload: {}) }

    it_behaves_like 'invalid cookbook'
  end

  context 'the user is sharing a cookbook with a zero-length README' do
    before(:each) { share_cookbook('zero-length-readme.tgz', user) }

    it_behaves_like 'invalid cookbook'
  end

  context 'the user uploads a cookbook with a README that has no extension' do
    before(:each) { share_cookbook('readme-no-extension.tgz', user) }

    it_behaves_like 'valid cookbook'
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

  context 'using integers for dependency versions' do
    before do
      share_cookbook('invalid-dependencies.tgz', user)
    end

    it 'returns a 400' do
      expect(response.status.to_i).to eql(400)
    end

    it 'returns an error code' do
      expect(json_body['error_code']).to_not be_nil
    end

    it 'returns an error message' do
      expect(json_body['error_messages'].first).to match(/not a valid Chef version constraint/)
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
