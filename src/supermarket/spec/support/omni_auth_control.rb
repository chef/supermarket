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
    chef_username = user.username.present? ? user.username : nil

    username = github_username || chef_username || 'github_johndoe'
    email = user.email.present? ? user.email : 'johndoe@example.com'

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
    chef_username = user.username.present? ? user.username : 'johndoe'
    email = user.email.present? ? user.email : 'johndoe@example.com'

    OmniAuth::AuthHash.new(
      provider: 'chef_oauth2',
      uid: chef_username,
      info: {
        username: chef_username,
        email: email,
        first_name: 'John',
        last_name: 'Doe',
        public_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKVuZCyYt/gLXeclgnEibmM0+o1hPNaGGls6/lFNJYa1VvoN7dNdvXIdC6cPcBAijZp/LJI6u2w0dIjo7H2lw8aYF1TgmrYzeuCy+OZjXvfk6ZCi2ls3AILsxfw8S74Gd06JB+nwYJmusF/b01Bn1ua9ywaIUpKf5ewP0aM/2nAcJn/1C+q/JyRSK0DrfajV+Tiw0jufblzx6mfvSMtFUresEAKnsmu1QJYH6aNAvBWIiz/Sh7uIBA5tHHCP43G/95tPP9wXw2Capp/aOX+PViwkGuh8ebJaYjPhV35jGGXFdUPkcHj/i14bxUVKFjUkcLataLW7DvcO4LQfZtRt0p'
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
