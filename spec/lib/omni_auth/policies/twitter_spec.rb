require 'spec_helper'
require 'omni_auth/policies/twitter'

describe OmniAuth::Policies::Twitter do
  let(:auth) do
    {
      'provider' => 'twitter',
      'uid' => '262914828',
      'info'=>{
        'nickname' => 'sethvargo',
        'name' => 'Seth Vargo',
        'location' => 'Pittsburgh, PA',
        'image' => 'http://pbs.twimg.com/profile_images/3253480536/4c1f5285466a932b39601471bf8e0781_normal.jpeg',
        'description' => 'Open Source. Chef. Ruby. Czar of the Misfit Toys @opscode. ΣΧ. Views are my own.',
        'urls'=>{
          'Website' => 'http://t.co/8TooeT38t7',
          'Twitter' => 'https://twitter.com/sethvargo'
        }
      },
      'credentials'=>{
        'token' => '262914828-aaa0a0aa0aaa000aaaa0aaa00aaa000a00000a00',
        'secret' => 'bbb1b1bb1bbb111bbbb1bbb11bbb111b11111b11'
      }
    }
  end

  subject { described_class.new(auth) }

  its(:first_name) { should eq('Seth') }
  its(:last_name) { should eq('Vargo') }
  its(:username) { should eq('sethvargo') }
  its(:image_url) { should eq('http://pbs.twimg.com/profile_images/3253480536/4c1f5285466a932b39601471bf8e0781_normal.jpeg') }
  its(:uid) { should eq('262914828') }
  its(:oauth_token) { should eq('262914828-aaa0a0aa0aaa000aaaa0aaa00aaa000a00000a00') }
  its(:oauth_secret) { should eq('bbb1b1bb1bbb111bbbb1bbb11bbb111b11111b11') }
end
