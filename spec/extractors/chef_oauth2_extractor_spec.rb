require 'spec_helper'

describe ChefOauth2Extractor do
  let(:auth) { OmniAuth.config.mock_auth[:chef_oauth2] }

  subject { described_class.new(auth) }

  its(:first_name)  { should eq('John') }
  its(:last_name)   { should eq('Doe') }
  its(:email)       { should eq('johndoe@example.com') }
  its(:username)    { should eq('johndoe') }
  its(:uid)         { should eq('12345') }
  its(:oauth_token) { should eq('oauth_token') }
  its(:public_key) { should eq('ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKVuZCyYt/gLXeclgnEibmM0+o1hPNaGGls6/lFNJYa1VvoN7dNdvXIdC6cPcBAijZp/LJI6u2w0dIjo7H2lw8aYF1TgmrYzeuCy+OZjXvfk6ZCi2ls3AILsxfw8S74Gd06JB+nwYJmusF/b01Bn1ua9ywaIUpKf5ewP0aM/2nAcJn/1C+q/JyRSK0DrfajV+Tiw0jufblzx6mfvSMtFUresEAKnsmu1QJYH6aNAvBWIiz/Sh7uIBA5tHHCP43G/95tPP9wXw2Capp/aOX+PViwkGuh8ebJaYjPhV35jGGXFdUPkcHj/i14bxUVKFjUkcLataLW7DvcO4LQfZtRt0p') }
end
