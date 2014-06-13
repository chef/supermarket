FactoryGirl.define do
  factory :account do
    association :user
    uid           { username }
    sequence(:username) { |n| "johndoe#{n}" }
    provider 'github'
    oauth_token   { SecureRandom.hex(15) }
    oauth_secret  { SecureRandom.hex(20) }
    oauth_expires { 10.days.from_now }
  end
end
