FactoryGirl.define do
  factory :user do
    first_name            'John'
    last_name             'Doe'
    password              'password'
    password_confirmation 'password'

    sequence(:email) { |n| "johndoe#{n}@example.com" }

    factory :admin, class: User do
      first_name 'Admin'
      last_name  'User'
      roles_mask 1
    end
  end
end
