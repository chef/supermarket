FactoryBot.define do
  factory :ownership_transfer_request do
    association :cookbook
    association :recipient, factory: :user
    association :sender, factory: :user
  end
end
