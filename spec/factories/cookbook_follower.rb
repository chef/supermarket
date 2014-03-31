FactoryGirl.define do
  factory :cookbook_follower do
    association :cookbook
    association :user
  end
end
