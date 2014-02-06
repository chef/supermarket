FactoryGirl.define do
  factory :icla_signature do
    association :user

    agreement   '1'
  end
end
