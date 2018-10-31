FactoryBot.define do
  factory :email do
    association :user
    email              { "#{user.username}@example.com" }
    confirmation_token { 'ABCD1234' }
    confirmed_at       { 1.day.ago }
  end
end
