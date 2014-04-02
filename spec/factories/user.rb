FactoryGirl.define do
  factory :user do
    first_name            'John'
    last_name             'Doe'

    sequence(:email) { |n| "johndoe#{n}@example.com" }

    after(:create) do |user, evaluator|
      create(:account, provider: 'chef_oauth2', user: user)
    end

    factory :admin, class: User do
      first_name 'Admin'
      last_name  'User'
      roles_mask 1
    end
  end
end
