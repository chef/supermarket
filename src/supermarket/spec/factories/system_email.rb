FactoryBot.define do
  factory :system_email do
    sequence(:name) { |n| "Awesome Email #{n}" }
  end
end
