module OmniAuthControl
  EXPIRATION = Time.current.to_i

  def self.stub_github!(user = User.new)
    OmniAuth.config.mock_auth[:github] = github_hash(user)
  end

  def self.stub_chef!(user = User.new)
    OmniAuth.config.mock_auth[:chef_oauth2] = chef_hash(user)
  end

  def self.github_hash(user = User.new)
    github_username = user.accounts.for('github').first.try(:username)
    chef_username = user.username.presence

    username = github_username || chef_username || 'github_johndoe'
    email = user.email.presence || 'johndoe@example.com'

    OmniAuth::AuthHash.new(
      provider: 'github',
      uid: username,
      info: {
        nickname: username,
        email: email,
        name: 'John Doe',
        image: 'https://image-url.com'
      },
      credentials: {
        token: 'oauth_token',
        expires: false
      }
    )
  end

  def self.chef_hash(user = User.new)
    chef_username = user.username.presence || 'johndoe'
    email = user.email.presence || 'johndoe@example.com'

    OmniAuth::AuthHash.new(
      provider: 'chef_oauth2',
      uid: chef_username,
      info: {
        username: chef_username,
        email: email,
        first_name: 'John',
        last_name: 'Doe',
        public_key: File.read('spec/support/key_fixtures/valid_public_key.pub')
      },
      credentials: {
        token: 'oauth_token',
        refresh_token: 'refresh_token',
        expires_at: EXPIRATION,
        expires: true
      }
    )
  end
end
