FactoryGirl.define do
  factory :organization_user do
    association :organization
    association :user
    admin       false
  end
end
