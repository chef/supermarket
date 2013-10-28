require 'spec_helper'

describe 'Users API' do
  context 'GET #index' do
    before do
      create_list(:user, 2)
      get '/api/users'
    end

    it 'is successful' do
      expect(response).to be_success
    end

    it 'is an array of user objects' do
      expect(parsed_response).to have(2).items
    end

    it 'has the correct keys' do
      expect(parsed_response.first).to have_key('id')
      expect(parsed_response.first).to have_key('name')
      expect(parsed_response.first).to have_key('link')
    end
  end

  context 'GET #show' do
    let(:account) { create(:account) }
    let(:email) { create(:email) }
    let(:icla_signature) { create(:icla_signature) }
    let(:user) { create(:user, accounts: [account], emails: [email], primary_email: email, icla_signatures: [icla_signature]) }

    before { get "/api/users/#{user.id}" }

    it 'is successful' do
      expect(response).to be_success
    end

    it 'has the correct values' do
      expect(parsed_response).to eq({
        'id'            => user.id,
        'prefix'        => user.prefix,
        'first_name'    => user.first_name,
        'middle_name'   => user.middle_name,
        'last_name'     => user.last_name,
        'suffix'        => user.suffix,
        'phone'         => ActionController::Base.helpers.number_to_phone(user.phone),
        'primary_email' => user.primary_email.email,
        'signed_icla'   => user.signed_icla?,
        'accounts' => [
          { 'uid' => account.uid },
        ],
        'emails' => [
          {
            'email'     => email.email,
            'confirmed' => email.confirmed?,
          }
        ],
      })
    end
  end
end
