require 'spec_helper'

describe OmniAuth::Policies::Github do
  let(:auth) do
    {
      'provider' => 'github',
      'uid' => '408570',
      'info' => {
        'nickname' => 'sethvargo',
        'email' => 'sethvargo@gmail.com',
        'name' => 'Seth Vargo',
        'image' => 'https://2.gravatar.com/avatar/87f282c6c2cdad13100dffe8c1daf77d?d=https%3A%2F%2Fidenticons.github.com%2Fb75f58301305183b958bf0488a88add8.png&r=x',
        'urls' => {
          'GitHub' => 'https://github.com/sethvargo',
          'Blog' => 'sethvargo.com'
        }
      },
      'credentials' => {
        'token' => 'aaa0a0aa0aaa000aaaa0aaa00aaa000a00000a00',
        'expires' => false
      }
    }
  end

  subject { described_class.new(auth) }

  its(:first_name) { should eq('Seth') }
  its(:last_name) { should eq('Vargo') }
  its(:email) { should eq('sethvargo@gmail.com') }
  its(:username) { should eq('sethvargo') }
  its(:image_url) { should eq('https://2.gravatar.com/avatar/87f282c6c2cdad13100dffe8c1daf77d?d=https%3A%2F%2Fidenticons.github.com%2Fb75f58301305183b958bf0488a88add8.png&r=x') }
  its(:uid) { should eq('408570') }
  its(:oauth_token) { should eq('aaa0a0aa0aaa000aaaa0aaa00aaa000a00000a00') }
end
