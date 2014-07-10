FactoryGirl.define do
  factory :contributor_request do
    association :user
    association :organization
  end
end
