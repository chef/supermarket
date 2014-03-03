module OmniAuth
  config.test_mode = true

  # Default
  config.mock_auth[:default] = OmniAuth::AuthHash.new(
    provider: 'default',
    uid: '12345',
    info: {
      nickname: 'johndoe',
      name: 'John Doe'
    },
    credentials: {
      token: 'oauth_token',
      secret: 'oauth_secret',
      expires: false
    }
  )
end
