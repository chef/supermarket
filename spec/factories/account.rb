FactoryGirl.define do
  factory :account do
    association   :user
    uid           { SecureRandom.hex(10) }
    username      { user.username }
    oauth_token   { SecureRandom.hex(15) }
    oauth_secret  { SecureRandom.hex(20) }
    oauth_expires { 10.days.from_now }
  end
end
