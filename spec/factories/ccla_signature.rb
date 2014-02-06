FactoryGirl.define do
  factory :ccla_signature do
    association :user
    association :organization

    agreement   '1'
  end
end
