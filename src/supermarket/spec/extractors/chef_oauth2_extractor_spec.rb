require 'spec_helper'

describe ChefOauth2Extractor do
  let(:auth) { OmniAuth.config.mock_auth[:chef_oauth2] }

  subject { described_class.new(auth) }

  describe '#first_name' do
    subject { super().first_name }
    it { should eq('John') }
  end

  describe '#last_name' do
    subject { super().last_name }
    it { should eq('Doe') }
  end

  describe '#email' do
    subject { super().email }
    it { should eq('johndoe@example.com') }
  end

  describe '#username' do
    subject { super().username }
    it { should eq('johndoe') }
  end

  describe '#uid' do
    subject { super().uid }
    it { should eq('johndoe') }
  end

  describe '#oauth_token' do
    subject { super().oauth_token }
    it { should eq('oauth_token') }
  end

  describe '#public_key' do
    subject { super().public_key }
    it { should eq('ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKVuZCyYt/gLXeclgnEibmM0+o1hPNaGGls6/lFNJYa1VvoN7dNdvXIdC6cPcBAijZp/LJI6u2w0dIjo7H2lw8aYF1TgmrYzeuCy+OZjXvfk6ZCi2ls3AILsxfw8S74Gd06JB+nwYJmusF/b01Bn1ua9ywaIUpKf5ewP0aM/2nAcJn/1C+q/JyRSK0DrfajV+Tiw0jufblzx6mfvSMtFUresEAKnsmu1QJYH6aNAvBWIiz/Sh7uIBA5tHHCP43G/95tPP9wXw2Capp/aOX+PViwkGuh8ebJaYjPhV35jGGXFdUPkcHj/i14bxUVKFjUkcLataLW7DvcO4LQfZtRt0p') }
  end
end
