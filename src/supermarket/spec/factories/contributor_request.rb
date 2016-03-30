FactoryGirl.define do
  factory :contributor_request do
    association :user
    association :organization
    association :ccla_signature
  end
end
