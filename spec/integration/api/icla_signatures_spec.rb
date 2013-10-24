require 'spec_helper'

describe 'Icla Signatures API' do
  context 'GET #index' do
    before do
      create_list(:icla_signature, 2)
      get '/api/icla-signatures'
    end

    it 'is successful' do
      expect(response).to be_success
    end

    it 'is an array of user objects' do
      expect(parsed_response).to have(2).items
    end

    it 'has the correct keys' do
      expect(parsed_response.first).to have_key('id')
      expect(parsed_response.first).to have_key('user')
      expect(parsed_response.first).to have_key('signed_at')
    end
  end

  context 'GET #show' do
    let(:icla_signature) { create(:icla_signature) }
    let(:user) { icla_signature.user }

    before { get "/api/icla-signatures/#{icla_signature.id}" }

    it 'is successful' do
      expect(response).to be_success
    end

    it 'has the correct values' do
      expect(parsed_response).to eq({
        'id'        => icla_signature.id,
        'signed_at' => icla_signature.signed_at.iso8601(3),
        'user' => {
          'id'   => user.id,
          'name' => user.name,
          'link' => user_url(user),
        }
      })
    end
  end
end
