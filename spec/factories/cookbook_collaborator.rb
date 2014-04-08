FactoryGirl.define do
  factory :cookbook_collaborator do
    association :cookbook
    association :user
  end
end
