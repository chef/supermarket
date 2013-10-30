require 'spec_helper'

describe TwitterExtractor do
let(:auth) { OmniAuth.config.mock_auth[:twitter] }

  subject { described_class.new(auth) }

  its(:first_name)   { should eq('John') }
  its(:last_name)    { should eq('Doe') }
  its(:username)     { should eq('johndoe') }
  its(:image_url)    { should eq('https://image-url.com') }
  its(:uid)          { should eq('12345') }
  its(:oauth_token)  { should eq('oauth_token') }
  its(:oauth_secret) { should eq('oauth_secret') }
end
