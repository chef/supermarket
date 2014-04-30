require 'spec_helper'

describe GithubExtractor do
  let(:auth) { OmniAuth.config.mock_auth[:github] }

  subject { described_class.new(auth) }

  its(:first_name)  { should eq('John') }
  its(:last_name)   { should eq('Doe') }
  its(:email)       { should eq('johndoe@example.com') }
  its(:username)    { should eq('github_johndoe') }
  its(:image_url)   { should eq('https://image-url.com') }
  its(:uid)         { should eq('github_johndoe') }
  its(:oauth_token) { should eq('oauth_token') }
end
