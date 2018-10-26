FactoryBot.define do
  factory :invitation do
    association :organization
    token { 'ABCD1234' }
    admin { true }

    sequence(:email) { |n| "johndoe#{n}@example.com" }
  end
end
