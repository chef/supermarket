FactoryGirl.define do
  factory :email do
    association        :user
    email              'jdoe@example.com'
    confirmation_token 'ABCD1234'
    confirmed_at       { 1.day.ago }
  end
end
