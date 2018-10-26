FactoryBot.define do
  factory :email_preference do
    association :user
    association :system_email
  end
end
