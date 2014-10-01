FactoryGirl.define do
  factory :unsubscribe_request do
    email_preference_name 'new_version'
    association :user
  end
end
