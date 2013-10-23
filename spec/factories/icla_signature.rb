FactoryGirl.define do
  factory :icla_signature do
    association :user
    signed_at   { 1.day.ago }
  end
end
