require 'spec_helper'

describe GithubExtractor do
  let(:auth) { OmniAuth.config.mock_auth[:github] }

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
    it { should eq('github_johndoe') }
  end

  describe '#image_url' do
    subject { super().image_url }
    it { should eq('https://image-url.com') }
  end

  describe '#uid' do
    subject { super().uid }
    it { should eq('github_johndoe') }
  end

  describe '#oauth_token' do
    subject { super().oauth_token }
    it { should eq('oauth_token') }
  end
end
