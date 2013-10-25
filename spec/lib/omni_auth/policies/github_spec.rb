require 'spec_helper'

describe OmniAuth::Policies::Github do
  let(:auth) { OmniAuth.config.mock_auth[:github] }

  subject { described_class.new(auth) }

  its(:first_name)  { should eq('John') }
  its(:last_name)   { should eq('Doe') }
  its(:email)       { should eq('johndoe@example.com') }
  its(:username)    { should eq('johndoe') }
  its(:image_url)   { should eq('https://image-url.com') }
  its(:uid)         { should eq('12345') }
  its(:oauth_token) { should eq('oauth_token') }
end
