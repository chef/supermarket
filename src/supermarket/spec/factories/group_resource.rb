FactoryBot.define do
  factory :group_resource do
    association :group
    association :resourceable, factory: :cookbook
  end
end
