FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "My Group #{n}" }
  end
end
