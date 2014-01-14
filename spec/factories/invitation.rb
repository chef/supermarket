FactoryGirl.define do
  factory :invitation do
    association :organization
    email       'johndoe@example.com'
    token       'ABCD1234'
    admin       true
  end
end
