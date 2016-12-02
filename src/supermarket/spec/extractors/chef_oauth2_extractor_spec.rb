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
    it { should eq(File.read('spec/support/key_fixtures/valid_public_key.pub')) }
  end
end
