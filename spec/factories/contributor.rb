FactoryGirl.define do
  factory :contributor do
    association :organization
    association :user
    admin false
  end
end
