FactoryGirl.define do
  factory :account do
    association   :user
    uid           'uid'
    username      'johndoe'
    oauth_token   'oauth_token'
    oauth_secret  'oauth_secret'
    oauth_expires { 10.days.from_now }
  end
end
