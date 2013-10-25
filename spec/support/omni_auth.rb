module OmniAuth
  config.test_mode = true

  # Default
  config.mock_auth[:default] = OmniAuth::AuthHash.new({
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
  })

  # GitHub
  config.mock_auth[:github] = OmniAuth::AuthHash.new({
    provider: 'github',
    uid: '12345',
    info: {
      nickname: 'johndoe',
      email: 'johndoe@example.com',
      name: 'John Doe',
      image: 'https://image-url.com',
    },
    credentials: {
      token: 'oauth_token',
      expires: false
    }
  })

  # Twitter
  config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
    provider: 'twitter',
    uid: '12345',
    info: {
      nickname: 'johndoe',
      name: 'John Doe',
      location: 'Pittsburgh, PA',
      image: 'https://image-url.com',
      description: 'This is a description',
    },
    credentials: {
      token: 'oauth_token',
      secret: 'oauth_secret'
    }
  })
end
