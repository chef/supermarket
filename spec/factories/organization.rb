FactoryGirl.define do
  factory :organization do
    ignore do
      ccla_signatures_count 2
    end

    after(:create) do |organization, evaluator|
      create_list(:ccla_signature, evaluator.ccla_signatures_count, organization: organization)
    end
  end
end
